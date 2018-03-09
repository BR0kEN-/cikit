module.exports = command => app => [
  app.get('passport').authenticate('bearer', {session: false}),
  require('./commands/' + command)(app),
];
