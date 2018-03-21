const listMiddleware = require('./list');

module.exports = async (manager, request, response) => {
  if (!request.body.group || !request.body.username) {
    throw new manager.app.errors.RuntimeError('The request body must contain "group" and "username"', 400, 'user_missing_data');
  }

  const group = request.body.group;

  if ('owner' === group) {
    throw new manager.app.errors.RuntimeError('The system cannot have multiple owners', 403, 'user_owner_exists');
  }

  const username = request.body.username;

  if (null !== await manager.getUser(username)) {
    throw new manager.app.errors.RuntimeError('Username is already taken', 400, 'user_name_taken');
  }

  try {
    await manager.ensureUser(username, group);
  }
  catch (error) {
    // This error can be thrown by the "user" model validation.
    if (error.errors && error.errors.group) {
      throw new manager.app.errors.RuntimeError('The group is unknown', 400, 'user_group_unknown');
    }

    throw error;
  }

  return listMiddleware(manager, request, response);
};
