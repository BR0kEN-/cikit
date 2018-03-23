process.env.NODE_ENV = 'test';

const chai = require('chai');

chai.should();
chai.use(require('chai-http'));

/**
 * @type {Application}
 */
const app = require('./app');
/**
 * @type {UserManager}
 */
const manager = require('../lib/user/UserManager')(app);
/**
 * @type {Object.<Function[]>}
 */
const request = require('./request')(app, chai);
/**
 * @type {Object.<Function[]>}
 */
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
      assert.response.error(await request.auth(suite.username, suite.code), suite);
    });
  });

  // Authenticate users from each group.
  // eslint-disable-next-line guard-for-in
  for (const group in users) {
    // The promise is not resolved for the moment so the "users" have
    // usernames as values.
    const username = users[group];

    it('should be authenticated as ' + username, async () => {
      const auth = await request.auth(username, await manager.generateTotpCode(username));

      assert.response.auth(auth);
      assert.response.list(await request.api(auth, 'get', 'droplet/list').send());
      assert.response.error(await request.api(auth, 'get', 'droplet/l1st').send(), {
        httpCode: 404,
        errorId: 404,
        error: 'Route not found',
      });

      // Assert that virtual property represents an internal ID.
      users[group].userId.should.be.equal(users[group]._id.toString());
    });
  }

  it('should fail up generating a TOTP code for an invalid user.', async () => {
    try {
      await manager.generateTotpCode('bla');
      throw new Error('This should never be reached');
    }
    catch (error) {
      error.message.should.be.eql('A user does not exist');
    }
  });

  it('should fail up accessing an authorized resource with an invalid token', async () => {
    const auth = await request.auth(users.viewer.username, await manager.generateTotpCode(users.viewer.username));

    // Initially we should successfully gain an access token.
    assert.response.auth(auth);
    // Then spoof the token to fail a request to an authorized resource.
    auth.body.access_token = 'bla';

    assert.response.error(await request.api(auth, 'get', 'droplet/list').send(), {
      httpCode: 401,
      errorId: 908,
      error: 'Access token not found',
    });
  });

  it('should fail up accessing an authorized resource with outdated token', async () => {
    const auth = await request.auth(users.manager.username, await manager.generateTotpCode(users.manager.username));

    // Initially we should successfully gain an access token.
    assert.response.auth(auth);
    // Obtain an object of current, valid access token.
    const token = await app.mongoose.models.AccessToken.findOne({token: auth.body.access_token});
    // Compulsorily grow old the token and save it.
    await token.update({created: token.created.setSeconds(token.created.getSeconds() - 86400)});

    assert.response.error(await request.api(auth, 'get', 'droplet/list').send(), {
      httpCode: 401,
      errorId: 909,
      error: 'Access token expired',
    });
  });

  it('should fail up accessing an authorized resource with an invalid role', async () => {
    const auth = await request.auth(users.owner.username, await manager.generateTotpCode(users.owner.username));
    const response = await request.api(auth, 'get', '_test/wrong-user-group').send();

    assert.response.error(response, {
      httpCode: 401,
      errorId: 911,
      error: 'Route requested an access for the unknown group',
    });

    response.body.should.not.have
      .property('brutality');
  });
});
