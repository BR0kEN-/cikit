const {ensureAuthorizedAccess} = require('../auth/functions');

/**
 * Ensures an authorized access to the resource.
 *
 * @param {String} requestedUserGroup
 *   The name of a group an authorized user should have in order
 *   to access the resource.
 * @param {String|Function} filenameOrFunction
 *   The path to file with callback or resource's callback itself.
 * @param {*} args
 *   An additional set of arguments for the resource's command.
 *
 * @return {function(*=)}
 *   A list of Express.js route's middleware.
 */
module.exports = (requestedUserGroup, filenameOrFunction, ...args) => {
  if (typeof filenameOrFunction === 'string') {
    filenameOrFunction = require('./' + filenameOrFunction);
  }

  return app => [
    // Every API resource requires an authentication.
    app.passport.authenticate('access-token', {session: false}),
    // If a user is logged in successfully its permissions is oughta check.
    ensureAuthorizedAccess(app, requestedUserGroup),
    // Do resource's actions.
    filenameOrFunction(app, ...args),
  ];
};
