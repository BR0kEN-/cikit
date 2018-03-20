const speakeasy = require('speakeasy');
const hostname = require('os').hostname();
const QRCode = require('qrcode');

const RuntimeError = require('../error/RuntimeError');

class UserManager {
  constructor(app) {
    this.app = app;
  }

  async revokeToken(tokenType, userId) {
    await this.app
      .get(tokenType)
      .remove({userId});
  }

  async revokeTokens(userId) {
    await Promise
      .all(['AccessToken', 'RefreshToken'].map(type => this.revokeToken(type, userId)));
  }

  async generateBarcode(user) {
    const totp = this.app.get('config').get('security:totp');

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
    return await this.app
      .get('User')
      .findOne({username});
  }

  async getUsers(conditions = null, projection = null) {
    return await this.app
      .get('User')
      .find(conditions, projection);
  }

  /**
   * @param {String} username
   * @param {String} group
   * @param {Boolean} recreate
   *
   * @return {Promise<{message: {String}, group: {String}, secret: {String}, barcode: {String}}>}
   */
  async ensureUser(username, group, recreate = false) {
    const log = this.app.get('log');
    const User = this.app.get('User');
    const config = this.app.get('config');
    const createUser = async (config, username, group) => {
      if ('owner' === group && null !== await User.findOne({group, username: {'$ne': username}})) {
        throw new RuntimeError('The system cannot have multiple owners', 403, config.get('errors:user_owner_exists'));
      }

      return new User({username, group}).save();
    };

    const user = await this
      .getUser(username)
      .then(async user => {
        if (recreate && null !== user) {
          log.debug('An account for %s will be re-created. This action will invalidate the belonged secret key.', username);

          return User
            .remove({_id: user.id})
            .then(createUser.bind(undefined, config, username, group));
        }

        if (null !== user) {
          log.debug('The "access" and "refresh" tokens for %s will be revoked.', username);

          return user;
        }

        log.debug('An account for %s will be created.', username);

        return createUser(config, username, group);
      });

    await this.revokeTokens(user.id);

    return user;
  }
}

module.exports = app => new UserManager(app);
