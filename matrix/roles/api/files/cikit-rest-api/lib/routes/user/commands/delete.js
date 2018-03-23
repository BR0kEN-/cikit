const listMiddleware = require('./list');

module.exports = async (app, request, response) => {
  const user = await app.managers.user.getUserByName(request.params.user);

  if (null === user) {
    throw new app.errors.RuntimeError('Cannot delete a non-existent user', 400, 'user_not_found');
  }

  // @todo It should't be possible to remove an owner.
  await user.remove();

  return listMiddleware(app, request, response);
};
