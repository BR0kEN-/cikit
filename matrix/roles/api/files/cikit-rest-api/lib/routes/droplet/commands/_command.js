const jsonpath = require('jsonpath');
const execSync = require('child_process').execSync;
const hostname = 'localhost';

module.exports = (app, endpoint, handler) => {
  const log = app.get('log');
  const isDev = app.get('isDev');

  return (request, response) => {
    const callback = handler(request, response);

    if (!(callback instanceof Function)) {
      log.debug('The "%s" endpoint made an early return (probably from cache).', endpoint);

      return null;
    }

    const command = `ANSIBLE_STDOUT_CALLBACK=json cikit matrix/droplet --droplet-${endpoint}${request.params.droplet ? '=' + request.params.droplet : ''} --limit=${hostname}`;
    const jsonPath = `$.plays[0].tasks[?(@.task.name == '${request.params.taskName}')].hosts.${hostname}`;

    log.debug('Running "%s"', command);

    return (async () => isDev ? require('./' + endpoint + '-example') : JSON.parse(await execSync(command)))()
      .then(output => {
        const stats = output.stats[hostname];

        log.debug('Applying JSON path query "%s"', jsonPath);

        return callback(jsonpath.query(output, jsonPath)[0], output, !stats.failures && !stats.unreachable, stats);
      })
      .catch(error => {
        log.error(error);

        response.json({
          error: error.toString ? error.toString() : error,
        });
      });
  };
};
