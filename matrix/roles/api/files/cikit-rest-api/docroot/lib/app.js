/**
 * @namespace Application
 */

/**
 * @param {String} dir
 *   The relative path to directory to discover.
 *
 * @return {Object}
 *   The list of discovered components.
 */
function discovery(dir) {
  const data = [];

  dir = __dirname + '/' + dir;

  fs.readdirSync(dir).forEach(name => {
    // The first character is a capital letter and ".js" is an extension.
    if (/^[A-Za-z].+?\.js/.test(name)) {
      data.push([path.basename(name, '.js'), require(dir + '/' + name)]);
    }
  });

  return data;
}

const fs = require('fs');
const path = require('path');
/**
 * @type {bodyParser}
 */
const bodyParser = require('body-parser');
/**
 * @type {Authenticator}
 */
const passport = require('passport');
/**
 * @type {Application}
 */
const app = require('express')();
/**
 * @type {Boolean}
 */
const isDev = 'development' === app.get('env');
/**
 * @type {nconf.Provider}
 */
const config = require('./config');
/**
 * The prefix of API routes.
 *
 * @type {String}
 */
const prefix = config.get('prefix');
/**
 * @var {winston.Logger} log
 * @var {Function} routeErrorHandler
 * @var {Function} globalErrorHandler
 */
const {log, routeErrorHandler, globalErrorHandler} = require('./log')(config, isDev);

/**
 * @memberOf Application#
 * @type {winston.Logger}
 */
app.log = log;

/**
 * @memberOf Application#
 * @type {Number}
 */
app.port = Number(process.env.PORT || config.get('port'));

/**
 * @memberOf Application#
 * @type {Boolean}
 */
app.isDev = isDev;

/**
 * @memberOf Application#
 * @type {nconf.Provider}
 */
app.config = config;

/**
 * @memberOf Application#
 */
app.passport = passport;

/**
 * @memberOf Application#
 * @type {Function}
 */
app.discovery = discovery;

/**
 * @memberOf Application#
 * @type {Object.<Error>}
 */
app.errors = require('./errors')(app);

/**
 * @memberOf Application#
 * @type {Mongoose}
 */
app.db = require('./db')(app);

/**
 * @memberOf Application#
 * @type {Object.<Object>}
 */
app.managers = Object.create(null);

for (const [name, manager] of discovery('./manager')) {
  app.managers[name] = manager(app);
}

for (const [, object] of discovery('./auth/strategy')) {
  passport.use(new object(app));
}

app.use(bodyParser.json());
app.use(bodyParser.urlencoded({extended: false}));
app.use(passport.initialize());

for (const [type, routes] of Object.entries(config.get('routes'))) {
  routes.forEach(path => {
    const stack = require('./route/' + path.replace(/\/:\w+/g, ''))(app);

    stack.unshift(routeErrorHandler);

    app[type](prefix + '/' + path, stack);
  });
}

// Set lazy-loaders for parameters in order to perform actions
// only after successful authentication and permissions check.
for (const [name, handler] of discovery('./param')) {
  app.param(name, (request, response, next, value) => {
    request.loaders = request.loaders || {};
    request.loaders[name] = handler.bind(undefined, value);

    return next();
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
