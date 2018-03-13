'use strict';

const mongooseModelNames = [
  'User',
  'AccessToken',
  'RefreshToken',
];

/**
 * @type {bodyParser}
 */
const bodyParser = require('body-parser');
/**
 * @type {Authenticator}
 */
const passport = require('passport');
/**
 * @type {Object}
 */
const app = require('express')();
/**
 * @type {nconf}
 */
const config = require('./config');
/**
 * @var {winston.Logger} log
 * @var {Function} routeErrorHandler
 * @var {Function} globalErrorHandler
 */
const {log, routeErrorHandler, globalErrorHandler} = require('./log')(module);
/**
 * @type {TotpCodeStrategy}
 */
const TotpCodeStrategy = require('./auth/strategy/TotpCodeStrategy');
/**
 * @type {AccessTokenStrategy}
 */
const AccessTokenStrategy = require('./auth/strategy/AccessTokenStrategy');

app.set('log', log);
app.set('port', Number(process.env.PORT || config.get('port') || 3000));
app.set('isDev', process.env.NODE_ENV === 'development');
app.set('crypto', require('crypto'));
app.set('config', config);
app.set('passport', passport);
app.set('mongoose', require('./mongoose')(app));

mongooseModelNames.forEach(name => app.set(name, require('./model/' + name)(app)));

passport.use(new TotpCodeStrategy(app));
passport.use(new AccessTokenStrategy(app));

app.use(bodyParser.json());
app.use(bodyParser.urlencoded({extended: false}));
app.use(passport.initialize());

for (const [type, routes] of Object.entries(config.get('routes'))) {
  routes.forEach(path => {
    const stack = require('./routes/' + path.replace(/\/:\w+/g, ''))(app);

    stack.unshift(routeErrorHandler);

    app[type]('/api/v1/' + path, stack);
  });
}

// Catch 404 and forward to an error handler.
app.use((request, response, next) => {
  response.status(404);

  log.debug('%s %d %s', request.method, response.statusCode, request.url);

  response.json({
    error: 'Route not found',
    errorId: response.statusCode,
  });
});

// 4 parameters must be declared, in order Express to treat the
// callback as an error handler. The "next" is unused and it must
// not be changed!
app.use((error, request, response, next) => globalErrorHandler(error, request, response));

module.exports = app;
