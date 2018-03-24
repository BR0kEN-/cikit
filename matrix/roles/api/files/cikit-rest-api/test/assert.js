const assertHttpCode = (response, code = 200) => response.should.have.status(code);

const assert = {
  response: {
    error: (response, suite) => {
      assertHttpCode(response, suite.httpCode);

      response.body.should.have
        .property('error')
        .eql(suite.error);

      response.body.should.have
        .property('errorId')
        .eql(suite.errorId);
    },
    auth: (response) => {
      assertHttpCode(response);

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
    list: (response) => {
      assertHttpCode(response);

      response.should.have
        .property('body')
        .to.be.an('array');
    },
  },
};

assert.response.auth.revoke = (response) => {
  assertHttpCode(response);

  response.body.should.have
    .property('status')
    .eql('ok');
};

assert.response.auth.setup = (response) => {
  assertHttpCode(response);

  response.body.should.have
    .property('qr');
};

module.exports = assert;
