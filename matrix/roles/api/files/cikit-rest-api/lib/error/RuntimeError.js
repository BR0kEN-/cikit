class RuntimeError extends Error {
  constructor(message, httpCode, errorId) {
    super();

    this.message = message;
    this.errorId = errorId;
    this.status = httpCode;
  }
}

module.exports = RuntimeError;
