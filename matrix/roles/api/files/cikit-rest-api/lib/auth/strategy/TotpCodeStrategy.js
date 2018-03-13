const Strategy = require('passport-strategy');
const RuntimeError = require('../../error/RuntimeError');
const generateTokens = require('../../auth/functions').generateTokens;

/**
 * @class TotpCodeStrategy
 * @classdesc Exchanges OTP code for the "access" and "refresh" tokens.
 */
class TotpCodeStrategy extends Strategy {
  constructor(app) {
    super();

    this.app = app;
    this.name = 'totp-code';
    this.user = app.get('User');
    this.config = app.get('config');
  }

  authenticate(request) {
    const code = request.body.code;
    const username = request.body.username;

    if (!code || !username) {
      throw new RuntimeError('The request body must contain "code" and "username"', 400, this.config.get('errors:totp_code_missing_data'));
    }

    (async () => {
      const user = await this.user.findOne({username});

      if (!user) {
        throw new RuntimeError('User not found', 404, this.config.get('errors:user_not_found'));
      }

      if (!user.isTotpValid(code)) {
        throw new RuntimeError('TOTP code invalid', 400, this.config.get('errors:totp_code_invalid'));
      }

      generateTokens(this.app, user.id).then(data => this.success(user, data));
    })();
  }
}

module.exports = TotpCodeStrategy;
