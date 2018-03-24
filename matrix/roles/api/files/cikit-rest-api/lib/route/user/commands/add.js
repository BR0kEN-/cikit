const listMiddleware = require('./list');

module.exports = async (app, request, response) => {
  if (!request.body.group || !request.body.username) {
    throw new app.errors.RuntimeError('The request body must contain "group" and "username"', 400, 'user_missing_data');
  }

  if (null !== await app.managers.user.getByName(request.body.username)) {
    throw new app.errors.RuntimeError('Username is already taken', 400, 'user_name_taken');
  }

  try {
    await app.managers.user.create(request.body.username, request.body.group);
  }
  catch (error) {
    // This error can be thrown by the "user" model validation.
    if (error.errors && error.errors.group) {
      throw new app.errors.RuntimeError('The group is unknown', 400, 'user_group_unknown');
    }

    throw error;
  }

  return listMiddleware(app, request, response);
};
