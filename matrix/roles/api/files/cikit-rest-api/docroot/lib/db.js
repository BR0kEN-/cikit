const mongoose = require('mongoose');

/**
 * @param {Application} app
 *   The application.
 *
 * @return {Mongoose}
 *   The "mongoose" database connection.
 */
module.exports = app => {
  mongoose.connect(app.config.get('db:uri'));
  mongoose.connection.once('open', () => app.log.debug('Connected to DB!'));
  mongoose.connection.on('error', error => app.log.error('Connection error:', error.message));

  app.db = mongoose;

  /**
   * @memberOf Application.db.models#
   * @type {
   *   {
   *     User: {Model},
   *     AccessToken: {Model},
   *     RefreshToken: {Model},
   *   }
   * }
   */
  for (const [, model] of app.discovery('./model')) {
    model(app);
  }

  return app.db;
};
