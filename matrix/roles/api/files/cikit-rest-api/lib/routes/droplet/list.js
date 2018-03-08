const host = 'localhost';
const task = 'Store the list of all droplets';
const shellCommand = 'ANSIBLE_STDOUT_CALLBACK=json cikit matrix/droplet --limit=' + host + ' --droplet-list';
const jsonPathQuery = '$.plays[0].tasks[?(@.task.name == "' + task + '")].hosts.' + host + '.msg.*';

module.exports = app => {
  const jsonpath = require('jsonpath');
  const execSync = require('child_process').execSync;
  const log = app.get('log');
  const isDev = app.get('isDev');

  return [
    app.get('passport').authenticate('bearer', {session: false}),
    (request, response) => (async () => isDev ? require('./list-example') : JSON.parse(await execSync(shellCommand)))()
      .then(output => {
        let droplets = [];

        jsonpath.query(output, jsonPathQuery).forEach(value => {
          let ports = {};
          // @example
          // @code
          // [
          //   '5b51632b9a30',
          //   'solita/ubuntu-systemd',
          //   '"/bin/bash -c \'exe..."',
          //   '2 months ago',
          //   'Up 13 days',
          //   '0.0.0.0:2201->22/tcp, 127.0.0.1:8001->80/tcp, 127.0.0.1:44301->443/tcp',
          //   'cikit01'
          // ]
          // @endcode
          value = value.split(/\s{2,}/);

          value[5].split(', ').forEach(entry => {
            // @example
            // @code
            // [
            //   '127.0.0.1:44301->443/tcp',
            //   '127.0.0.1:44301',
            //   '443',
            //   'tcp'
            // ]
            // @endcode
            entry = /(\d+\.\d+\.\d+\.\d+:\d+)->(\d+)\/(\w+)/.exec(entry);

            let from = entry[1].split(':');

            ports[entry[2]] = {
              type: entry[3],
              from: {
                ip: from[0],
                port: from[1],
              },
            };
          });

          droplets.push({
            id: value[0],
            name: value[6],
            created: value[3],
            status: value[4],
            ports: ports,
          });
        });

        response.json(droplets);
      })
      .catch(error => log.error(error)),
  ];
};
