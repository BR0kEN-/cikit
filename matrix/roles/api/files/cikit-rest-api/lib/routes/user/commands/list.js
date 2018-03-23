module.exports = async (app, request, response) => response.json(await app.managers.user.getUsers(null, {
  username: true,
  created: true,
  secret: true,
  group: true,
}));
