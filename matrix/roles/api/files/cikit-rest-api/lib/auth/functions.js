const speakeasy = require('speakeasy');
const crypto = require('crypto');

/**
 * Destroy old and generate new "access" and "refresh" tokens.
 *
 * @param {Object} app
 *   The application.
 * @param {String} userId
 *   The ID of a user.
 *
 * @return {{token_type: {String}, expires_in: {Number}, access_token: {String}, refresh_token: {String}}}
 *   The Bearer's token object.
 */
async function generateTokens(app, userId) {
  const [AccessToken, RefreshToken] = await Promise.all(['AccessToken', 'RefreshToken'].map(async name => {
    await app.mongoose.models[name].remove({userId});

    return await new app.mongoose.models[name]({userId, token: crypto.randomBytes(32).toString('hex')}).save();
  }));

  return {
    token_type: 'Bearer',
    expires_in: app.config.get('security:tokenLife'),
    access_token: AccessToken.toString(),
    refresh_token: RefreshToken.toString(),
  };
}

/**
 * Generates the TOTP secret key based on the config.
 *
 * @param {Object} totp
 *   The TOTP definition.
 * @param {String} totp.type
 *   The type of TOTP.
 * @param {Number} totp.length
 *   The length of TOTP secret.
 * @param {String} totp.issuer
 *   The issuer of TOTP secret.
 *
 * @return {String}
 *   The TOTP secret.
 *
 * @link https://en.wikipedia.org/wiki/Time-based_One-time_Password_Algorithm
 */
function generateTotpSecret(totp) {
  return speakeasy.generateSecret({length: totp.length, otpauth_url: false})[totp.type];
}

/**
 * Checks whether TOTP token is valid.
 *
 * @param {Object} totp
 *   The TOTP definition.
 * @param {String} totp.type
 *   The type of TOTP.
 * @param {Number} totp.length
 *   The length of TOTP secret.
 * @param {String} totp.issuer
 *   The issuer of TOTP secret.
 * @param {String} secret
 *   The secret key, generated for the authenticating app.
 * @param {String} token
 *   The token, generated by authenticating app, that needs to be verified.
 *
 * @return {Boolean}
 *   A state of check.
 */
function isTotpTokenValid(totp, secret, token) {
  return speakeasy.totp.verify({secret, token, encoding: totp.type});
}

/**
 * Checks whether the user is authorized and belongs to requested group.
 *
 * @param {Application} app
 *   The application.
 * @param {String} requestedGroup
 *   The name of a group, the route require the user to have.
 *
 * @return {Function}
 *   Express.js middleware.
 */
function ensureAuthorizedAccess(app, requestedGroup) {
  return (request, response, next) => {
    if (!request.user) {
      throw new app.errors.RuntimeError('Unauthorized', 401, 'user_unauthorized');
    }

    if (!request.user.group) {
      throw new app.errors.RuntimeError('The user does not belong to a group', 401, 'user_ungrouped');
    }

    const userGroups = app.config.get('security:user:groups');

    if (!userGroups.hasOwnProperty(request.user.group)) {
      throw new app.errors.RuntimeError('The user is in an unknown group', 401, 'user_group_unknown');
    }

    if (!userGroups.hasOwnProperty(requestedGroup)) {
      throw new app.errors.RuntimeError('Route requested an access for the unknown group', 401, 'route_group_unknown');
    }

    if (
      // A user belongs to the requested group.
      requestedGroup === request.user.group ||
      // A user's group inherits the requested group.
      -1 !== userGroups[requestedGroup].indexOf(request.user.group)
    ) {
      return next();
    }

    throw new app.errors.RuntimeError('Access denied', 403, 'route_access_denied');
  };
}

module.exports = {
  generateTokens,
  generateTotpSecret,
  isTotpTokenValid,
  ensureAuthorizedAccess,
};
