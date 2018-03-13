const RuntimeError = require('../../error/RuntimeError');
const BearerStrategy = require('passport-http-bearer');

/**
 * @class AccessTokenStrategy
 * @classdesc Authenticates user by an access token.
 */
class AccessTokenStrategy extends BearerStrategy {
  constructor(app) {
    super(AccessTokenStrategy.verify.bind(undefined, app.get('config'), app.get('User'), app.get('AccessToken')));

    this.name = 'access-token';
  }

  static async verify(config, user, accessToken, token, done) {
    token = await accessToken.findOne({token});

    if (!token) {
      throw new RuntimeError('Access token not found', 404, config.get('errors:access_token_not_found'));
    }

    if (Math.round((Date.now() - token.created) / 1000) > config.get('security:tokenLife')) {
      await token.remove();

      throw new RuntimeError('Access token expired', 401, config.get('errors:access_token_expired'));
    }

    user = await user.findById(token.userId);

    if (!user) {
      throw new RuntimeError('User not found', 404, config.get('errors:user_not_found'));
    }

    done(null, user);
  }
}

module.exports = AccessTokenStrategy;
