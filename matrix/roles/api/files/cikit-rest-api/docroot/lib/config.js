const nconf = require('nconf');

nconf.argv().env();

nconf.file('defaults', {
  file: './config.json',
});

module.exports = nconf;
