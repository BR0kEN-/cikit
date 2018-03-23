const BearerStrategy = require('passport-http-bearer');

/**
 * @class AccessTokenStrategy
 * @classdesc Authenticates user by an access token.
 */
class AccessTokenStrategy extends BearerStrategy {
  /**
   * @param {Application} app
   *   The application.
   */
  constructor(app) {
    super(AccessTokenStrategy.verify.bind(undefined, app));

    this.name = 'access-token';
  }

  /**
   * @param {Application} app
   *   The application.
   * @param {String} token
   *   The access token.
   * @param {Function} done
   *   A callback to execute if user passed the authorization.
   */
  static async verify(app, token, done) {
    token = await app.db.models.AccessToken
      .findOne({token})
      .populate('user');

    if (!token) {
      throw new app.errors.RuntimeError('Access token not found', 401, 'access_token_not_found');
    }

    if (Math.round((Date.now() - token.created) / 1000) > app.config.get('security:tokenLife')) {
      await token.remove();

      throw new app.errors.RuntimeError('Access token expired', 401, 'access_token_expired');
    }

    done(null, await token.user);
  }
}

module.exports = AccessTokenStrategy;
