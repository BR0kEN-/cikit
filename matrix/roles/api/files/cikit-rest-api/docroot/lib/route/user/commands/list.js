module.exports = async (app, request, response) => response.json(await app.managers.user.getMultiple(null, {
  username: true,
  created: true,
  secret: true,
  group: true,
}));
