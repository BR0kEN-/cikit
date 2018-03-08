module.exports = app => {
  const oauth2orize = require('oauth2orize');

  const tokenLife = app.get('config').get('security:tokenLife');
  const passport = app.get('passport');
  const crypto = app.get('crypto');
  const log = app.get('log');

  const User = app.get('User');
  const AccessToken = app.get('AccessToken');
  const RefreshToken = app.get('RefreshToken');

  // Create the OAuth 2.0 server.
  const aserver = oauth2orize.createServer();
  const errFn = (callback, error) => {
    if (error) {
      return callback(error);
    }
  };

  // Destroy any old tokens and generates a new access and refresh token
  const generateTokens = (data, done) => {
    // Curries in `done` callback so we don't need to pass it
    const errorHandler = errFn.bind(undefined, done);
    let tokens = {RefreshToken, AccessToken};

    Object.keys(tokens).forEach(key => {
      tokens[key].remove(data, errorHandler);

      data.token = crypto.randomBytes(32).toString('hex');

      tokens[key] = {
        value: data.token,
        object: new tokens[key](data),
      };
    });

    tokens.RefreshToken.object.save(errorHandler);
    tokens.AccessToken.object.save(error => {
      if (error) {
        log.error(error);

        return done(error);
      }

      done(null, tokens.AccessToken.value, tokens.RefreshToken.value, {
        expires_in: tokenLife,
      });
    });
  };

  // Exchange username and password for an access token.
  aserver.exchange(oauth2orize.exchange.password((client, username, password, scope, done) => {
    User.findOne({username: username}, (error, user) => {
      if (error) {
        return done(error);
      }

      if (!user || !user.checkPassword(password)) {
        return done(null, false);
      }

      generateTokens({
        userId: user.userId,
        clientId: client.clientId,
      }, done);
    });
  }));

  // Exchange "refreshToken" for an access token.
  aserver.exchange(oauth2orize.exchange.refreshToken((client, refreshToken, scope, done) => {
    RefreshToken.findOne({token: refreshToken, clientId: client.clientId}, (error, token) => {
      if (error) {
        return done(error);
      }

      if (!token) {
        return done(null, false);
      }

      User.findById(token.userId, (error, user) => {
        if (error) {
          return done(error);
        }

        if (!user) {
          return done(null, false);
        }

        generateTokens({
          userId: user.userId,
          clientId: client.clientId,
        }, done);
      });
    });
  }));

  // "token" middleware handles client requests to exchange authorization
  // grants for access tokens. Based on the grant type being exchanged, the
  // above exchange middleware will be invoked to handle the request. Clients
  // must authenticate when making requests to this endpoint.
  return [
    passport.authenticate(['basic', 'oauth2-client-password'], {session: false}),
    aserver.token(),
    aserver.errorHandler(),
  ];
};
