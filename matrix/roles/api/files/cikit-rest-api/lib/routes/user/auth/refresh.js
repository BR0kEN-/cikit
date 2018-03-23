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
    const token = await app.mongoose.models.RefreshToken.findOne({token: refreshToken});

    if (!token) {
      throw new app.errors.RuntimeError('Refresh token not found', 401, 'refresh_token_not_found');
    }

    const user = await app.mongoose.models.User.findById(token.userId);

    done(null, true, await user.generateAccessToken());
  };

  // Exchange "refresh" token for an "access" token.
  authServer.exchange(oauth2orize.exchange.refreshToken(callback.bind(undefined, app)));

  return [
    authServer.token(),
  ];
};
