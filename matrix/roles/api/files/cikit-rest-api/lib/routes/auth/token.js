const oauth2orize = require('oauth2orize');
const authServer = oauth2orize.createServer();
const RuntimeError = require('../../error/RuntimeError');
const generateTokens = require('../../auth/functions').generateTokens;

module.exports = app => {
  const callback = async (app, client, refreshToken, scope, done) => {
    const token = await app.get('RefreshToken').findOne({token: refreshToken});
    const config = app.get('config');

    if (!token) {
      throw new RuntimeError('Refresh token not found', 404, config.get('errors:refresh_token_not_found'));
    }

    const user = await app.get('User').findById(token.userId);

    if (!user) {
      throw new RuntimeError('User not found', 404, config.get('errors:user_not_found'));
    }

    done(null, true, await generateTokens(app, user.id));
  };

  // Exchange "refresh" token for an "access" token.
  authServer.exchange(oauth2orize.exchange.refreshToken(callback.bind(undefined, app)));

  return [
    authServer.token(),
  ];
};
