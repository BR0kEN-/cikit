const jsonpath = require('jsonpath');
const execSync = require('child_process').execSync;
const RuntimeError = require('../../../error/RuntimeError');
const hostname = 'localhost';

module.exports = (app, command, handler) => {
  const log = app.get('log');
  const isDev = app.get('isDev');
  const config = app.get('config');

  return (request, response) => {
    const callback = handler(request, response);
    const jsonPath = `$.plays[0].tasks[?(@.task.name == '${request.params.taskName}')].hosts.${hostname}`;
    const shellCommand = `ANSIBLE_STDOUT_CALLBACK=json cikit matrix/droplet --droplet-${command}${request.params.droplet ? '=' + request.params.droplet : ''} --limit=${hostname}`;

    log.debug('Running "%s"', shellCommand);

    return (async () => isDev ? require('./examples/' + command) : JSON.parse(await execSync(shellCommand)))()
      .then(output => {
        const stats = output.stats[hostname];

        log.debug('Applying JSON path query "%s"', jsonPath);

        if (stats.failures !== 0 || stats.unreachable !== 0) {
          throw new RuntimeError(output, 501, config.get('errors:ansible_command_failed'));
        }

        return callback(jsonpath.query(output, jsonPath)[0], output);
      });
  };
};
