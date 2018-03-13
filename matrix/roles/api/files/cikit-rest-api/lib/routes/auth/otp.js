const ResponseError = require('../../error/ResponseError');

module.exports = app => [
  // We must define the callback in order to not allow the passport
  // to perform the original actions after success.
  app.get('passport').authenticate('totp-code', {session: false}, (error, user, data) => {
    throw new ResponseError(data);
  }),
];
