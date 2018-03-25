const {execSync} = require('child_process');
const jsonpath = require('jsonpath');
const hostname = 'localhost';

module.exports = (app, command, handler) => async (request, response) => {
  const callback = handler(request, response);
  const command1 = `ANSIBLE_STDOUT_CALLBACK=json cikit matrix/droplet --droplet-${command}${request.params.droplet ? '=' + request.params.droplet : ''} --limit=${hostname}`;
  const parse = (data, query) => {
    const jsonPath = `$.plays[0].tasks[${query}].hosts.${hostname}`;

    app.log.debug('Applying JSON path query "%s"', jsonPath);

    return jsonpath.query(JSON.parse(data), jsonPath)[0];
  };

  try {
    app.log.debug('Running "%s"', command1);

    return callback(parse(await execSync(command1), `?(@.task.name == '${request.params.taskName}')`));
  }
  catch (error) {
    throw new app.errors.RuntimeError(parse(error.stdout, '-1:').stderr, 400, 'ansible_command_failed');
  }
};
