const mongoose = require('mongoose');

/**
 * @param {Application} app
 *   The application.
 *
 * @return {Mongoose}
 *   The "mongoose" database connection.
 */
module.exports = app => {
  mongoose.connect(app.config.get('mongoose:uri'));
  mongoose.connection.once('open', () => app.log.debug('Connected to DB!'));
  mongoose.connection.on('error', error => app.log.error('Connection error:', error.message));

  app.mongoose = mongoose;

  /**
   * @memberOf Mongoose#models
   * @type {
   *   {
   *     User: {Model},
   *     AccessToken: {Model},
   *     RefreshToken: {Model},
   *   }
   * }
   */
  const models = app.discovery('./model');

  for (const model in models) {
    if (models.hasOwnProperty(model)) {
      models[model](app);
    }
  }

  return app.mongoose;
};
