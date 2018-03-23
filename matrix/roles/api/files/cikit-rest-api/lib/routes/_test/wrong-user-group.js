module.exports = require('../_resource')('v1ewer', app => (request, response) => {
  response.json({
    brutality: 'FATALITY',
  });
});
