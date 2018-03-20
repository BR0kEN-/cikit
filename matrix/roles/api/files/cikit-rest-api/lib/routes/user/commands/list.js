module.exports = async (manager, config, request, response) => response.json(await manager.getUsers(null, {
  username: true,
  created: true,
  secret: true,
  group: true,
}));
