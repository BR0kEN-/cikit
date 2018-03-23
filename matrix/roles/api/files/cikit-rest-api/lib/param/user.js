module.exports = async (username, app) => {
  const user = await app.managers.user.getUserByName(username);

  if (null !== user) {
    return user;
  }

  throw new app.errors.RuntimeError('User not found', 400, 'user_not_found');
};
