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
   *   The application.
   *
   * @return {Array.<Function>}
   *   A list of middleware.
   */
  return app => {
    const userGroups = app.config.get('security:user:groups');

    if (!userGroups.hasOwnProperty(requestedUserGroup)) {
      throw new Error('You are trying to set a route handler with unknown permissions!');
    }

    return [
      // Every API resource requires an authentication.
      app.passport.authenticate('access-token', {session: false}),
      // If a user is logged in successfully its permissions is oughta check.
      (request, response, next) => {
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
      async (request, response, next) => {
        request.payload = Object.create(null);

        if (request.hasOwnProperty('loaders')) {
          for (const [name, handler] of Object.entries(request.loaders)) {
            request.payload[name] = await handler(app);
          }
        }

        next();
      },
      // Do resource's actions.
      filenameOrFunction(app, ...args),
    ];
  };
};
