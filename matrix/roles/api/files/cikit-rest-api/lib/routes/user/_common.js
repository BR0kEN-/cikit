const UserManager = require('../../user/UserManager');

module.exports = command => {
  const middleware = require('./commands/' + command);

  return require('../_resource')('owner', app => middleware.bind(undefined, UserManager(app), app.get('config')));
};
