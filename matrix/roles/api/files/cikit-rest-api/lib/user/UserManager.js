const speakeasy = require('speakeasy');
const hostname = require('os').hostname();
const QRCode = require('qrcode');

class UserManager {
  /**
   * @param {Application} app
   */
  constructor(app) {
    this.app = app;
  }

  async revokeToken(tokenType, userId) {
    await this.app.mongoose.models[tokenType].remove({userId});
  }

  async revokeTokens(userId) {
    await Promise
      .all(['AccessToken', 'RefreshToken'].map(type => this.revokeToken(type, userId)));
  }

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

  async getUser(username) {
    return await this.app.mongoose.models.User.findOne({username});
  }

  async getUsers(conditions = null, projection = null) {
    return await this.app.mongoose.models.User.find(conditions, projection);
  }

  /**
   * @param {String} username
   * @param {String} group
   * @param {Boolean} recreate
   *
   * @return {Promise<{message: {String}, group: {String}, secret: {String}, barcode: {String}}>}
   */
  async ensureUser(username, group, recreate = false) {
    const createUser = async (username, group) => {
      if ('owner' === group && null !== await this.app.mongoose.models.User.findOne({group, username: {'$ne': username}})) {
        throw new this.app.errors.RuntimeError('The system cannot have multiple owners', 403, 'user_owner_exists');
      }

      return new this.app.mongoose.models.User({username, group}).save();
    };

    const user = await this
      .getUser(username)
      .then(async user => {
        if (recreate && null !== user) {
          this.app.log.debug('An account for %s will be re-created. This action will invalidate the belonged secret key.', username);

          return this.app.mongoose.models.User
            .remove({_id: user.id})
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
