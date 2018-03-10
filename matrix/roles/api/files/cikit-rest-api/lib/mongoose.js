module.exports = app => {
  const mongoose = require('mongoose');
  const log = app.get('log');

  mongoose.connect(app.get('config').get('mongoose:uri'));
  mongoose.connection.once('open', () => log.info('Connected to DB!'));
  mongoose.connection.on('error', error => log.error('Connection error:', error.message));

  return mongoose;
};
