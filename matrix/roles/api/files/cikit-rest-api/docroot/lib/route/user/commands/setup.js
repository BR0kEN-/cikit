/**
 * @param {Application} app
 *   The manager of users.
 * @param {Object} request
 *   The request to a server.
 * @param {Object} response
 *   Server's response.
 */
module.exports = async (app, request, response) => {
  response.json({
    qr: await request.payload.user.generateBarcode(),
    secret: request.payload.user.secret,
  });
};
