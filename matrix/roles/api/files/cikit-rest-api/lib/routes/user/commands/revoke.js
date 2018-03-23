/**
 * @param {Application} app
 *   The manager of users.
 * @param {Object} request
 *   The request to a server.
 * @param {Object} response
 *   Server's response.
 */
module.exports = async (app, request, response) => {
  const user = await app.managers.user.getUserByName(request.params.user);

  if (null === user) {
    throw new app.errors.RuntimeError('Cannot revoke tokens of non-existent user', 400, 'user_not_found');
  }

  // Allow revoking for ourselves and for anyone by owner.
  if (request.user.id === user.id || app.managers.user.isOwner(request.user)) {
    await user.revokeAccess();

    response.json({
      status: 'ok',
    });
  }
  else {
    throw app.errors.RuntimeError('Only system owner can revoke access for others', 401, 'user_unauthorized');
  }
};

// All user resources are available for owners only, but this one is an exception.
module.exports.group = 'viewer';
