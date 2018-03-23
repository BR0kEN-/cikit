/**
 * @type {nconf}
 */
const config = require('../lib/config');
/**
 * @type {Array.<String>}
 */
const routes = config.get('routes');

// Append testing routes.
routes.use
  .push('_test/wrong-user-group');

// Reload routes configuration.
config.set('routes', routes);

module.exports = require('../lib/app');
