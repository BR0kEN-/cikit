const BearerStrategy = require('passport-http-bearer');

/**
 * @class AccessTokenStrategy
 * @classdesc Authenticates user by an access token.
 */
class AccessTokenStrategy extends BearerStrategy {
  constructor(app) {
    super(AccessTokenStrategy.verify.bind(undefined, app));

    this.name = 'access-token';
  }

  /**
   * @param {Application} app
   * @param {String} token
   * @param {Function} done
   *
   * @return {Promise<void>}
   */
  static async verify(app, token, done) {
    token = await app.mongoose.models.AccessToken.findOne({token});

    if (!token) {
      throw new app.errors.RuntimeError('Access token not found', 404, 'access_token_not_found');
    }

    if (Math.round((Date.now() - token.created) / 1000) > app.config.get('security:tokenLife')) {
      await token.remove();

      throw new app.errors.RuntimeError('Access token expired', 401, 'access_token_expired');
    }

    const user = await app.mongoose.models.User.findById(token.userId);

    if (!user) {
      throw new app.errors.RuntimeError('User not found', 404, 'user_not_found');
    }

    done(null, user);
  }
}

module.exports = AccessTokenStrategy;
