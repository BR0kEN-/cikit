class ResponseError extends Error {
  constructor(payload) {
    super();

    this.payload = payload;
  }
}

module.exports = ResponseError;
