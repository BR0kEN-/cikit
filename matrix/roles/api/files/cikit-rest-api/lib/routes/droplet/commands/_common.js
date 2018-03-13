const list = require('./list');
const command = require('./_command');

module.exports = (task, taskName) => app => {
  const listCommand = list(app);

  return command(app, task, (request, response) => {
    request.params.taskName = taskName.replace('[droplet]', request.params.droplet);

    return () => listCommand(request, response);
  });
};
