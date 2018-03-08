const winston = require('winston');

winston.emitErrs = true;

module.exports = (module) => {
  return new winston.Logger({
    exitOnError: false,
    transports: [
      new winston.transports.File({
        level: 'info',
        filename: './all.log',
        handleException: true,
        colorize: false,
        maxFiles: 2,
        maxSize: 5242880,
        json: true,
      }),
      new winston.transports.Console({
        level: 'debug',
        label: module.filename.split('/').slice(-2).join('/'),
        handleException: true,
        colorize: true,
        json: false,
      })
    ]
  });
};
