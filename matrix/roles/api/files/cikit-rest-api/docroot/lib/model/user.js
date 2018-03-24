const speakeasy = require('speakeasy');
const hostname = require('os').hostname();
const crypto = require('crypto');
const QRCode = require('qrcode');

module.exports = app => {
  const totp = app.config.get('security:totp');

  function removeTokens(createNew) {
    return Promise.all(['AccessToken', 'RefreshToken'].map(async name => {
      const data = {user: this};
      await app.db.models[name].remove(data);

      if (!createNew) {
        return null;
      }

      data.token = crypto.randomBytes(32).toString('hex');

      return await new app.db.models[name](data).save();
    }));
  }

  const schema = new app.db.Schema({
    username: {
      type: String,
      unique: true,
      required: true,
    },
    secret: {
      type: String,
      unique: true,
      required: true,
      default: () => {
        return speakeasy.generateSecret({length: totp.length, otpauth_url: false})[totp.type];
      },
    },
    created: {
      type: Date,
      default: Date.now,
    },
    group: {
      type: String,
      enum: Object.keys(app.config.get('security:user:groups')),
      default: 'viewer',
      required: true,
    },
  });

  schema.methods.toString = function () {
    return this.username;
  };

  schema.methods.isTotpValid = function (code) {
    return speakeasy.totp.verify({
      secret: this.secret,
      token: code,
      encoding: totp.type,
    });
  };

  schema.methods.generateTotp = function () {
    return speakeasy.totp({
      secret: this.secret,
      encoding: totp.type,
    });
  };

  /**
   * @return {String}
   *   A URL suitable for use with an authenticating app.
   */
  schema.methods.generateBarcodeUrl = function () {
    return speakeasy.otpauthURL({
      // The label must be encoded because otherwise
      // QR code will be invalid.
      label: encodeURIComponent(hostname),
      secret: this.secret,
      // The issues can be an unprocessed text.
      issuer: `${totp.issuer} (${this.username})`,
      encoding: totp.type,
    });
  };

  schema.methods.generateBarcode = async function () {
    return await QRCode.toDataURL(this.generateBarcodeUrl());
  };

  /**
   * Destroy old and generate new "access" and "refresh" tokens.
   *
   * @return {{token_type: {String}, expires_in: {Number}, access_token: {String}, refresh_token: {String}}}
   *   The Bearer's token object.
   */
  schema.methods.generateAccessToken = async function () {
    const [accessToken, refreshToken] = await removeTokens.call(this, true);

    return {
      token_type: 'Bearer',
      expires_in: app.config.get('security:tokenLife'),
      access_token: accessToken.toString(),
      refresh_token: refreshToken.toString(),
    };
  };

  schema.methods.revokeAccess = async function () {
    await removeTokens.call(this, false);
  };

  schema.methods.isOwner = function () {
    return 'owner' === this.group;
  };

  return app.db.model('User', schema);
};
