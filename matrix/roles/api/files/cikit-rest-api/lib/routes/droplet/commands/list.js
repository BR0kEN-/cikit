const Cache = require('sync-disk-cache');
const cache = new Cache('droplet');

module.exports = (app, useCache = false) => require('./_command')(app, 'list', (request, response) => {
  request.params.taskName = 'Store the list of all droplets';

  // Cache is used only if exist and "list" resource has been queried explicitly.
  if (useCache && cache.has('list')) {
    return response.json(JSON.parse(cache.get('list').value));
  }

  return (result, output, status) => {
    if (!status) {
      return response.json({output});
    }

    const list = result.msg.map(value => {
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

      // In a case the "value" array will contain 6 items it means that
      // droplet is stopped.
      if (6 === value.length) {
        value[6] = value[5];
      }
      else {
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
      }

      return {
        id: value[0],
        name: value[6],
        created: value[3],
        status: value[4],
        ports: ports,
      };
    });

    cache.set('list', JSON.stringify(list));

    return response.json(list);
  };
});
