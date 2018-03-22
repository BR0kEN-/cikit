const speakeasy = require('speakeasy');
const hostname = require('os').hostname();
const QRCode = require('qrcode');

class UserManager {
  /**
   * @param {Application} app
   *   The application.
   */
  constructor(app) {
    this.app = app;
  }

  /**
   * @param {String} tokenType
   *   The type of token (a name of "mongoose" model).
   * @param {Number} userId
   *   The ID of a user.
   */
  async revokeToken(tokenType, userId) {
    await this.app.mongoose.models[tokenType].remove({userId});
  }

  /**
   * @param {Number} userId
   *   The ID of a user.
   */
  async revokeTokens(userId) {
    await Promise
      .all(['AccessToken', 'RefreshToken'].map(type => this.revokeToken(type, userId)));
  }

  /**
   * @param {Object} user
   *   The user's object.
   *
   * @return {Promise.<String>}
   *   A Base64 encoded PNG.
   */
  async generateBarcode(user) {
    const totp = this.app.config.get('security:totp');

    return await QRCode.toDataURL(speakeasy.otpauthURL({
      // The label must be encoded because otherwise
      // QR code will be invalid.
      label: encodeURIComponent(hostname),
      secret: user.secret,
      // The issues can be an unprocessed text.
      issuer: `${totp.issuer} (${user.username})`,
      encoding: totp.type,
    }));
  }

  async generateTotpCode(user) {
    const totp = this.app.config.get('security:totp');

    if ('string' === typeof user) {
      user = await this.getUser(user);
    }

    if (null === user) {
      throw new Error('A user does not exist');
    }

    return speakeasy.totp({
      secret: user.secret,
      encoding: totp.type,
    });
  }

  /**
   * @param {String} username
   *   The name of a user.
   *
   * @return {Promise.<Object>|null}
   *   The user's object.
   */
  async getUser(username) {
    return await this.app.mongoose.models.User.findOne({username});
  }

  /**
   * @param {Object} [conditions=null]
   *   The list of conditions.
   * @param {Object} [projection=null]
   *   The list of properties to return (http://bit.ly/1HotzBo).
   *
   * @return {Promise.<Object[]>|null}
   *   A list of users.
   */
  async getUsers(conditions = null, projection = null) {
    return await this.app.mongoose.models.User.find(conditions, projection);
  }

  /**
   * Checks whether the user is a system owner.
   *
   * @param {Object|String} user
   *   The user's object or the name of a group.
   *
   * @return {Boolean}
   *   A state of check.
   */
  static isOwner(user) {
    return 'owner' === ('string' === typeof user ? user : user.group);
  }

  /**
   * @param {String} username
   *   The name of a user.
   * @param {String} group
   *   The name of a user's group.
   * @param {Boolean} recreate
   *   An indicator for removing an existing user and creating it again. This
   *   can be useful in order to regenerate TOTP secret.
   *
   * @return {Object}
   *   The user's object.
   */
  async ensureUser(username, group, recreate = false) {
    const createUser = async (username, group) => {
      if (this.constructor.isOwner(group) && null !== await this.app.mongoose.models.User.findOne({group, username: {$ne: username}})) {
        throw new this.app.errors.RuntimeError('The system cannot have multiple owners', 403, 'user_owner_exists');
      }

      return new this.app.mongoose.models.User({username, group}).save();
    };

    const user = await this
      .getUser(username)
      .then(async user => {
        if (recreate && null !== user) {
          this.app.log.debug('An account for %s will be re-created. This action will invalidate the belonged secret key.', username);

          return this
            .removeUser(user)
            .then(createUser.bind(undefined, username, group));
        }

        if (null !== user) {
          this.app.log.debug('The "access" and "refresh" tokens for %s will be revoked.', username);

          return user;
        }

        this.app.log.debug('An account for %s will be created.', username);

        return createUser(username, group);
      });

    await this.revokeTokens(user.id);

    return user;
  }
}

module.exports = app => new UserManager(app);
