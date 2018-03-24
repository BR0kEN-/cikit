const oauth2orize = require('oauth2orize');
const authServer = oauth2orize.createServer();

/**
 * @param {Application} app
 *   The application.
 *
 * @return {Function[]}
 *   The list of middleware.
 */
module.exports = app => {
  const callback = async (app, client, refreshToken, done) => {
    const token = await app.db.models.RefreshToken
      .findOne({token: refreshToken})
      .populate('user');

    if (!token) {
      throw new app.errors.RuntimeError('Refresh token not found', 401, 'refresh_token_not_found');
    }

    done(null, true, await token.user.generateAccessToken());
  };

  // Exchange "refresh" token for an "access" token.
  authServer.exchange(oauth2orize.exchange.refreshToken(callback.bind(undefined, app)));

  return [
    authServer.token(),
  ];
};
