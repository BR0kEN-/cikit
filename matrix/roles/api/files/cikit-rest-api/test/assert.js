module.exports = {
  response: {
    error: (response, suite) => {
      response.should.have
        .status(suite.httpCode);

      response.body.should.have
        .property('error')
        .eql(suite.error);

      response.body.should.have
        .property('errorId')
        .eql(suite.errorId);
    },
    auth: (response) => {
      response.should.have
        .status(200);

      response.body.should.have
        .property('token_type')
        .eql('Bearer');

      response.body.should.have
        .property('expires_in')
        .eql(7200);

      response.body.should.have
        .property('access_token')
        .length(64);

      response.body.should.have
        .property('refresh_token')
        .length(64);
    },
  },
};
