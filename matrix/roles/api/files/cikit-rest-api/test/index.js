process.env.NODE_ENV = 'test';

const chai = require('chai');

chai.should();
chai.use(require('chai-http'));

/**
 * @type {Application}
 */
const app = require('../lib/app');
/**
 * @type {UserManager}
 */
const manager = require('../lib/user/UserManager')(app);
const {authRequest, apiRequest} = require('./request')(app, chai);
const assert = require('./assert');

describe('user', () => {
  let owner = null;
  let users = {
    owner: 'I_AM_OWNER',
    viewer: 'I_AM_VIEWER',
    manager: 'I_AM_MANAGER',
  };

  before(async () => {
    const owners = await manager.getUsers({group: 'owner'});

    if (0 < owners.length) {
      app.log.debug('An existing system owner will be temporarily removed.');
      // Store an existing owner in memory to recreate it afterward.
      owner = owners[owners.length - 1];
      // Remove an existing owner to create a stub for tests.
      await owner.remove();
    }

    // Create a stub user for every group.
    for (const [group, username] of Object.entries(users)) {
      users[group] = await manager.ensureUser(username, group);
    }
  });

  after(async () => {
    // Remove stub users.
    // eslint-disable-next-line guard-for-in
    for (const group in users) {
      await users[group].remove();
    }

    // Restore an owner.
    if (null !== owner) {
      new app.mongoose.models.User(owner.toObject()).save();
    }
  });

  // Different stages of an invalid access token retrieval.
  [
    {
      reason: 'TOTP token is missing',
      username: users.viewer,
      code: '',
      httpCode: 400,
      errorId: 901,
      error: 'The request body must contain "code" and "username"',
    },
    {
      reason: 'TOTP token is incorrect',
      username: users.manager,
      code: 'bla',
      httpCode: 400,
      errorId: 902,
      error: 'TOTP code invalid',
    },
    {
      reason: 'user does not exists',
      username: 'null',
      code: 'bla',
      httpCode: 400,
      errorId: 903,
      error: 'User not found',
    },
  ].forEach(suite => {
    it('should fail up with an invalid request because ' + suite.reason, async () => {
      assert.response.error(await authRequest(suite.username, suite.code), suite);
    });
  });

  // Authenticate users from each group.
  // eslint-disable-next-line guard-for-in
  for (const group in users) {
    // The promise is not resolved for the moment so the "users" have
    // usernames as values.
    const username = users[group];

    it('should be authenticated as ' + username, async () => {
      const auth = await authRequest(username, await manager.generateTotpCode(username));

      assert.response.auth(auth);

      const response = await apiRequest(auth, 'get', 'droplet/list').send();

      response.should.have
        .status(200);

      response.should.have
        .property('body')
        .to.be.an('array');

      // Assert that virtual property represents an internal ID.
      users[group].userId.should.be.equal(users[group]._id.toString());
    });
  }

  it('should fail up accessing an authorized resource with an invalid token', async () => {
    const auth = await authRequest(users.viewer.username, await manager.generateTotpCode(users.viewer.username));

    // Initially we should successfully gain an access token.
    assert.response.auth(auth);
    // Then spoof the token to fail a request to an authorized resource.
    auth.body.access_token = 'bla';

    assert.response.error(await apiRequest(auth, 'get', 'droplet/list').send(), {
      httpCode: 401,
      errorId: 908,
      error: 'Access token not found',
    });
  });

  it('should fail up accessing an authorized resource with outdated token', async () => {
    const auth = await authRequest(users.viewer.username, await manager.generateTotpCode(users.viewer.username));

    // Initially we should successfully gain an access token.
    assert.response.auth(auth);
    // Obtain an object of current, valid access token.
    const token = await app.mongoose.models.AccessToken.findOne({token: auth.body.access_token});
    // Compulsorily grow old the token and save it.
    await token.update({created: token.created.setSeconds(token.created.getSeconds() - 86400)});

    assert.response.error(await apiRequest(auth, 'get', 'droplet/list').send(), {
      httpCode: 401,
      errorId: 909,
      error: 'Access token expired',
    });
  });
});
