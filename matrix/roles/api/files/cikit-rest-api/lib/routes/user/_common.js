module.exports = command => {
  const middleware = require('./commands/' + command);

  return require('../_resource')(middleware.group || 'owner', app => middleware.bind(undefined, app));
};
