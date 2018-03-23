module.exports = app => {
  /**
   * @type {
   *   {
   *     ResponseError: {ResponseError},
   *     RuntimeError: {RuntimeError},
   *   }
   * }
   */
  const errors = Object.create(null);

  for (const [name, object] of app.discovery('./error')) {
    errors[name] = object.bind(null, app.config);
  }

  return errors;
};
