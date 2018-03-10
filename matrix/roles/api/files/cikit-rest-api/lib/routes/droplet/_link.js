module.exports = (command, ...args) => {
  command = require('./commands/' + command);

  return app => [
    app.get('passport').authenticate('bearer', {session: false}),
    command(app, ...args),
  ];
};
