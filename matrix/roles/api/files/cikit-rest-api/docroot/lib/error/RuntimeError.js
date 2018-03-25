class RuntimeError extends Error {
  constructor(config, message, httpCode, errorId) {
    super();

    this.message = message;
    this.status = httpCode;
    this.errorId = config.get('errors:' + errorId);
  }
}

module.exports = RuntimeError;
