const RuntimeError = require('../../../error/RuntimeError');
const listMiddleware = require('./list');

module.exports = async (manager, config, request, response) => {
  const user = await manager.getUser(request.params.user);

  if (null === user) {
    throw new RuntimeError('Cannot delete a non-existent user', 400, config.get('errors:user_not_found'));
  }

  await user.remove();

  return listMiddleware(manager, config, request, response);
};
