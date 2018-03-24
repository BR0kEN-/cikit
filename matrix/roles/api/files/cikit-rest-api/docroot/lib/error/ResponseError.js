class ResponseError extends Error {
  constructor(config, payload) {
    super();

    this.payload = payload;
  }
}

module.exports = ResponseError;
