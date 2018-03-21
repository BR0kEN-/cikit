/**
 * @param {UserManager} manager
 *   The manager of users.
 * @param {Object} request
 *   The request to a server.
 * @param {Object} response
 *   Server's response.
 */
module.exports = async (manager, request, response) => {
  const user = await manager.getUser(request.params.user);

  if (null === user) {
    throw new manager.app.errors.RuntimeError('Cannot revoke tokens of non-existent user', 400, 'user_not_found');
  }

  await manager.revokeTokens(user.userId);

  response.json({
    status: 'ok',
  });
};
