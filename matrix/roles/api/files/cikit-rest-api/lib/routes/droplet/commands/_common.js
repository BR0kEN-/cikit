module.exports = (endpoint, taskName) => {
  return app => {
    const listCommand = require('./list')(app);

    return require('./_command')(app, endpoint, (request, response) => {
      request.params.taskName = taskName.replace('[droplet]', request.params.droplet);

      return (result, output, status) => status
        ? listCommand(request, response)
        : response.json({output});
    });
  };
};
