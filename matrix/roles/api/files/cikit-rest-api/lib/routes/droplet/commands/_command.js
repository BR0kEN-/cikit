const jsonpath = require('jsonpath');
const execSync = require('child_process').execSync;
const hostname = 'localhost';

module.exports = (app, command, handler) => (request, response) => {
  const callback = handler(request, response);
  const jsonPath = `$.plays[0].tasks[?(@.task.name == '${request.params.taskName}')].hosts.${hostname}`;
  const shellCommand = `ANSIBLE_STDOUT_CALLBACK=json cikit matrix/droplet --droplet-${command}${request.params.droplet ? '=' + request.params.droplet : ''} --limit=${hostname}`;

  app.log.debug('Running "%s"', shellCommand);

  return (async () => app.isProd ? JSON.parse(await execSync(shellCommand)) : require('./examples/' + command))()
    .then(output => {
      const stats = output.stats[hostname];

      app.log.debug('Applying JSON path query "%s"', jsonPath);

      if (0 !== stats.failures || 0 !== stats.unreachable) {
        throw new app.errors.RuntimeError(output, 501, 'ansible_command_failed');
      }

      return callback(jsonpath.query(output, jsonPath)[0], output);
    });
};
