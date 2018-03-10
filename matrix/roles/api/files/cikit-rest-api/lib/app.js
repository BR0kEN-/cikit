'use strict';

const bodyParser = require('body-parser');
const passport = require('passport');
const app = require('express')();
const log = require('./log')(module);
const config = require('./config');

app.set('log', log);
app.set('port', Number(process.env.PORT || config.get('port') || 3000));
app.set('isDev', Boolean(process.env.DEV));
app.set('crypto', require('crypto'));
app.set('config', config);
app.set('passport', passport);
app.set('mongoose', require('./mongoose')(app));

require('./auth')(app);

app.use(bodyParser.json());
app.use(bodyParser.urlencoded({extended: false}));
app.use(passport.initialize());

for (const [type, routes] of Object.entries(config.get('routes'))) {
  routes.forEach(path => app[type]('/api/v1/' + path, require('./routes/' + path.replace(/\/:\w+/g, ''))(app)));
}

// Catch 404 and forward to an error handler.
app.use((request, response, next) => {
  response.status(404);
  log.debug('%s %d %s', request.method, response.statusCode, request.url);
  response.json({
    error: 'Not found',
  });
});

app.use((error, request, response, next) => {
  response.status(error.status || 500);
  log.error('%s %d %s', request.method, response.statusCode, error.message);
  response.json({
    error: error.message,
  });
});

module.exports = app;
