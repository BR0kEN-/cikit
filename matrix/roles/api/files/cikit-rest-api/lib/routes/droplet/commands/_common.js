const command = require('./_command');
const list = require('./list');

module.exports = (endpoint, taskName) => app => {
  const listCommand = list(app);

  return command(app, endpoint, (request, response) => {
    request.params.taskName = taskName.replace('[droplet]', request.params.droplet);

    return (result, output, status) => status
      ? listCommand(request, response)
      : response.json({output});
  });
};
