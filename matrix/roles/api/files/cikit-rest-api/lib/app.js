'use strict';

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
  const data = Object.create(null);

  dir = __dirname + '/' + dir;

  fs
    .readdirSync(dir)
    .forEach(name => {
      if (/[A-Z]/.test(name)) {
        const extension = path.extname(name);

        if ('.js' === extension) {
          data[path.basename(name, extension)] = require(dir + '/' + name);
        }
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
const {log, routeErrorHandler, globalErrorHandler} = require('./log')(module);

/**
 * @memberOf Application#
 * @type {Function}
 */
app.discovery = discovery;

/**
 * @memberOf Application#
 * @type {winston.Logger}
 */
app.log = log;

/**
 * @memberOf Application#
 * @type {Number}
 */
app.port = Number(process.env.PORT || config.get('port') || 3000);

/**
 * @memberOf Application#
 * @type {Boolean}
 */
app.isDev = 'development' === app.get('env');

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
 * @type {Object.<Error>}
 */
app.errors = require('./errors')(app);

/**
 * @memberOf Application#
 * @type {Mongoose}
 */
app.mongoose = require('./mongoose')(app);

for (const [, object] of Object.entries(discovery('./auth/strategy'))) {
  passport.use(new object(app));
}

app.use(bodyParser.json());
app.use(bodyParser.urlencoded({extended: false}));
app.use(passport.initialize());

for (const [type, routes] of Object.entries(config.get('routes'))) {
  routes.forEach(path => {
    const stack = require('./routes/' + path.replace(/\/:\w+/g, ''))(app);

    stack.unshift(routeErrorHandler);

    app[type](prefix + '/' + path, stack);
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
