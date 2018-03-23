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
  if ('string' === typeof filenameOrFunction) {
    filenameOrFunction = require('./' + filenameOrFunction);
  }

  /**
   * @param {Application} app
   */
  return app => [
    // Every API resource requires an authentication.
    app.passport.authenticate('access-token', {session: false}),
    // If a user is logged in successfully its permissions is oughta check.
    (request, response, next) => {
      const userGroups = app.config.get('security:user:groups');

      if (!userGroups.hasOwnProperty(requestedUserGroup)) {
        throw new app.errors.RuntimeError('Route requested an access for the unknown group', 401, 'route_group_unknown');
      }

      if (
        // A user belongs to the requested group.
        requestedUserGroup === request.user.group ||
        // A user's group inherits the requested group.
        -1 !== userGroups[requestedUserGroup].indexOf(request.user.group)
      ) {
        return next();
      }

      throw new app.errors.RuntimeError('Access denied', 403, 'route_access_denied');
    },
    // Do resource's actions.
    filenameOrFunction(app, ...args),
  ];
};
