/**
 * @param {Application} app
 *   The application.
 *
 * @return {Function[]}
 *   The list of middleware.
 */
module.exports = app => [
  // We must define the callback in order to not allow the passport
  // to perform the original actions after success.
  app.passport.authenticate('totp-code', {session: false}, (error, user, data) => {
    throw new app.errors.ResponseError(data);
  }),
];
