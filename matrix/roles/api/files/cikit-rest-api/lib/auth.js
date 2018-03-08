module.exports = app => {
  const passport = app.get('passport');
  const tokenLife = app.get('config').get('security:tokenLife');

  const BasicStrategy = require('passport-http').BasicStrategy;
  const BearerStrategy = require('passport-http-bearer').Strategy;
  const ClientPasswordStrategy = require('passport-oauth2-client-password').Strategy;

  const User = require('./model/user')(app);
  const Client = require('./model/client')(app);
  const AccessToken = require('./model/accessToken')(app);
  const RefreshToken = require('./model/refreshToken')(app);

  app.set('User', User);
  app.set('Client', Client);
  app.set('AccessToken', AccessToken);
  app.set('RefreshToken', RefreshToken);

  // Client Password - HTTP Basic authentication
  // Client Password - credentials in the request body
  [BasicStrategy, ClientPasswordStrategy].forEach(object => {
    passport.use(new object((usernameOrClientId, passwordOrClientSecret, done) => {
      Client.findOne({clientId: usernameOrClientId}, (error, client) => {
        if (error) {
          return done(error);
        }

        if (!client) {
          return done(null, false);
        }

        if (client.clientSecret !== passwordOrClientSecret) {
          return done(null, false);
        }

        return done(null, client);
      });
    }));
  });

  // Bearer Token strategy
  // https://tools.ietf.org/html/rfc6750
  passport.use(new BearerStrategy((accessToken, done) => {
    AccessToken.findOne({token: accessToken}, (error, token) => {
      if (error) {
        return done(error);
      }

      if (!token) {
        return done(null, false);
      }

      if (Math.round((Date.now() - token.created) / 1000) > tokenLife) {
        AccessToken.remove({token: accessToken}, error => {
          if (error) {
            return done(error);
          }
        });

        return done(null, false, {
          message: 'Token expired',
        });
      }

      User.findById(token.userId, (error, user) => {
        if (error) {
          return done(error);
        }

        if (!user) {
          return done(null, false, {
            message: 'Unknown user',
          });
        }

        done(null, user, {
          scope: '*',
        });
      });
    });
  }));
};
