const speakeasy = require('speakeasy');
const hostname = require('os').hostname();
const QRCode = require('qrcode');

const RuntimeError = require('../error/RuntimeError');

module.exports = (app, username, group, recreate) => {
  const config = app.get('config');
  const totp = config.get('security:totp');
  const log = app.get('log');

  const User = app.get('User');
  const AccessToken = app.get('AccessToken');
  const RefreshToken = app.get('RefreshToken');

  User
    .findOne({username})
    .then(async user => {
      if (recreate && null !== user) {
        log.debug('An account for %s will be re-created. This action will invalidate the belonged secret key.', username);

        return User
          .remove({_id: user.id})
          .then(() => new User({username, group}).save());
      }

      if ('owner' === group && null !== await User.findOne({group, username: {'$ne': username}})) {
        throw new RuntimeError('The system cannot have multiple owners', 403, config.get('errors:user_owner_exists'));
      }

      if (null !== user) {
        log.debug('The "access" and "refresh" tokens for %s will be revoked.', username);

        return user;
      }

      log.debug('An account for %s will be created.', username);

      return new User({username, group}).save();
    })
    .then(async user => {
      // Revoke tokens.
      await AccessToken.remove({userId: user.id});
      await RefreshToken.remove({userId: user.id});

      console.log({
        message:
          'Open base64-encoded PNG in a browser and scan QR code by your authenticator' +
          'app (e.g. Google Authenticator) or input the "secret" code manually to add' +
          'an integration.' +
          "\n\n" +
          'Keep this data private or remove them at all if an integration is added to' +
          'an authenticating app. Later, having an access to the service via SSH, you' +
          'will be able to recreate 2FA secret key.',
        group: user.group,
        secret: user.secret,
        barcode: await QRCode
          .toDataURL(speakeasy.otpauthURL({
            // The label must be encoded because otherwise
            // QR code will be invalid.
            label: encodeURIComponent(hostname),
            secret: user.secret,
            // The issues can be an unprocessed text.
            issuer: totp.issuer,
            encoding: totp.type,
          })),
      });
    });
};
