const Strategy = require('passport-strategy');
const generateTokens = require('../../auth/functions').generateTokens;

/**
 * @class TotpCodeStrategy
 * @classdesc Exchanges OTP code for the "access" and "refresh" tokens.
 */
class TotpCodeStrategy extends Strategy {
  /**
   * @param {Application} app
   */
  constructor(app) {
    super();

    this.app = app;
    this.name = 'totp-code';
  }

  authenticate(request) {
    const code = request.body.code;
    const username = request.body.username;

    if (!code || !username) {
      throw new this.app.errors.RuntimeError('The request body must contain "code" and "username"', 400, 'totp_code_missing_data');
    }

    (async () => {
      const user = await this.app.mongoose.models.User.findOne({username});

      if (!user) {
        throw new this.app.errors.RuntimeError('User not found', 404, 'user_not_found');
      }

      if (!user.isTotpValid(code)) {
        throw new this.app.errors.RuntimeError('TOTP code invalid', 400, 'totp_code_invalid');
      }

      generateTokens(this.app, user.id).then(data => this.success(user, data));
    })();
  }
}

module.exports = TotpCodeStrategy;
