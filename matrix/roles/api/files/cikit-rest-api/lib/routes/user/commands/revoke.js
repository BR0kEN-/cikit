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

  // Allow revoking for ourselves and for anyone by owner.
  if (request.user.id === user.id || manager.constructor.isOwner(request.user)) {
    await manager.revokeTokens(user.userId);

    response.json({
      status: 'ok',
    });
  }
  else {
    throw new manager.app.errors.RuntimeError('Only system owner can revoke access for others', 401, 'user_unauthorized');
  }
};

// All user resources are available for owners only, but this one is an exception.
module.exports.group = 'viewer';
