class RuntimeError extends Error {
  constructor(config, message, httpCode, errorId) {
    super();

    this.message = message;
    this.errorId = config.get('errors:' + errorId);
    this.status = httpCode;
  }
}

module.exports = RuntimeError;
