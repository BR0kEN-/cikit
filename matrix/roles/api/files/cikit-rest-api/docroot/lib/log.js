const winston = require('winston');
const ResponseError = require('./error/ResponseError');

function logger(label, isDev) {
  const transports = [
    new winston.transports.File({
      level: 'info',
      filename: `/var/log/${label}.log`,
      handleException: true,
      colorize: false,
      maxFiles: 2,
      maxSize: 5242880,
      json: true,
    }),
  ];

  if (isDev) {
    transports.push(
      new winston.transports.Console({
        label,
        level: 'debug',
        handleException: true,
        colorize: true,
        json: false,
      })
    );
  }

  return new winston.Logger({
    transports,
    exitOnError: false,
  });
}

function globalErrorHandler(logger, error, request, response) {
  if (response.headersSent) {
    // The response has already been sent.
  }
  else if (error instanceof ResponseError) {
    response.json(error.payload);
  }
  else {
    error.status = error.status || 500;
    error.errorId = error.errorId || 0;
    error.message = error.message || 'Internal server error';

    response.status(error.status);
    logger.error('%d %s - %s (%d)', response.statusCode, request.method, error.message, error.errorId);

    response.json({
      error: error.message.toString ? error.message.toString() : error.message,
      errorId: error.errorId,
    });
  }
}

function routeErrorHandler(logger, request, response, next) {
  const handler = (logger, request, response, self, error) => {
    globalErrorHandler(logger, error, request, response);
    process.removeListener('unhandledRejection', self);
  };

  // @todo Unfortunately there's no nicer way in Express.js to handle promises rejections globally.
  // @link https://stackoverflow.com/questions/33410101/unhandled-rejections-in-express-applications
  process.once('unhandledRejection', handler.bind(undefined, logger, request, response, handler));

  return next();
}

winston.emitErrs = true;

module.exports = (config, isDev) => {
  const log = logger(config.get('db:uri').split('/').slice(-1).join(), isDev);

  return {
    log,
    routeErrorHandler: routeErrorHandler.bind(undefined, log),
    globalErrorHandler: globalErrorHandler.bind(undefined, log),
  };
};
