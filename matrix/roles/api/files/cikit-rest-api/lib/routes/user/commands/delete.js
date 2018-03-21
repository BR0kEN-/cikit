const listMiddleware = require('./list');

module.exports = async (manager, request, response) => {
  const user = await manager.getUser(request.params.user);

  if (null === user) {
    throw new manager.app.errors.RuntimeError('Cannot delete a non-existent user', 400, 'user_not_found');
  }

  await user.remove();

  return listMiddleware(manager, request, response);
};
