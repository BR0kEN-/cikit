const listMiddleware = require('./list');

module.exports = async (app, request, response) => {
  // @todo It should't be possible to remove an owner.
  await request.params.user.remove();

  return listMiddleware(app, request, response);
};
