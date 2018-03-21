module.exports = app => {
  /**
   * @type {
   *   {
   *     ResponseError: {ResponseError},
   *     RuntimeError: {RuntimeError},
   *   }
   * }
   */
  const errors = app.discovery('./error');

  for (const [name, object] of Object.entries(errors)) {
    errors[name] = object.bind(null, app.config);
  }

  return errors;
};
