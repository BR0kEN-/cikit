process.env.NODE_ENV = 'test';

const Cache = require('sync-disk-cache');
const chai = require('chai');

chai.should();
chai.use(require('chai-http'));

/**
 * @type {Application}
 */
const app = require('../lib/app');
/**
 * @type {Object.<Function[]>}
 */
const request = require('./request')(app, chai);
/**
 * @type {Object.<Function[]>}
 */
const assert = require('./assert');

const denied = {
  httpCode: 403,
  errorId: 912,
  error: 'Access denied',
};

describe('The developer', () => {
  it('should not be able to set a middleware for a route with an unknown group', () => {
    try {
      require('../lib/route/_resource')('v1ewer', () => () => {})(app);
      throw new Error('This should never be reached!');
    }
    catch (error) {
      error.message.should.be.eql('You are trying to set a route handler with unknown permissions!');
    }
  });
});

describe('The user', () => {
  let owner = null;
  let users = {
    owner: 'I_AM_OWNER',
    viewer: 'I_AM_VIEWER',
    manager: 'I_AM_MANAGER',
  };

  before(async () => {
    const owners = await app.managers.user.getMultiple({group: 'owner'});

    if (0 < owners.length) {
      // Store an existing owner in memory to recreate it afterward.
      owner = owners[owners.length - 1];
      // Remove an existing owner to create a stub for tests.
      await owner.remove();
    }

    // Create a stub user for every group.
    for (const [group, username] of Object.entries(users)) {
      users[group] = await app.managers.user.create(username, group);
    }

    // Clear droplets cache.
    new Cache('droplet').clear();
  });

  after(async () => {
    // Remove stub users.
    // eslint-disable-next-line guard-for-in
    for (const group in users) {
      await users[group].remove();
    }

    // Restore an owner.
    if (null !== owner) {
      new app.db.models.User(owner.toObject()).save();
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
      reason: 'an account does not exist',
      username: 'null',
      code: 'bla',
      httpCode: 400,
      errorId: 903,
      error: 'User not found',
    },
  ].forEach(suite => {
    it(`should be informed about an invalid request because ${suite.reason}`, async () => {
      assert.response.error(await request.auth(suite.username, suite.code), suite);
    });
  });

  // Authenticate users from each group.
  // eslint-disable-next-line guard-for-in
  for (const group in users) {
    // The promise is not resolved for the moment so the "users" have
    // usernames as values.
    it('should be authenticated as ' + users[group], async () => {
      const auth = await request.auth(users[group]);

      assert.response.auth(auth);
      assert.response.list(await request.api(auth, 'get', 'droplet/list'));
      assert.response.error(await request.api(auth, 'get', 'droplet/l1st'), {
        httpCode: 404,
        errorId: 404,
        error: 'Route not found',
      });
    });
  }

  it('should not be able to access the resource with an invalid access token', async () => {
    const auth = await request.auth(users.viewer);

    // Initially we should successfully gain an access token.
    assert.response.auth(auth);
    // Then spoof the token to fail a request to an authorized resource.
    auth.body.access_token = 'bla';

    assert.response.error(await request.api(auth, 'get', 'droplet/list'), {
      httpCode: 401,
      errorId: 908,
      error: 'Access token not found',
    });
  });

  it('should not be able to access the resource with an outdated access token', async () => {
    const auth = await request.auth(users.manager);

    // Initially we should successfully gain an access token.
    assert.response.auth(auth);
    // Obtain an object of current, valid access token.
    const token = await app.db.models.AccessToken.findOne({token: auth.body.access_token});
    // Compulsorily grow old the token and save it.
    await token.update({created: token.created.setSeconds(token.created.getSeconds() - 86400)});
    // Ensure the "toString()" method of token's object returns an actual token.
    token.token.should.be.eql(token.toString());

    assert.response.error(await request.api(auth, 'get', 'droplet/list'), {
      httpCode: 401,
      errorId: 909,
      error: 'Access token expired',
    });
  });

  ['viewer', 'manager'].forEach(group => {
    it(`should not be able to access the "user/*" endpoints as "${group}"`, async () => {
      const auth = await request.auth(users[group]);

      // Ensure the user is authenticated.
      assert.response.auth(auth);

      // Cannot see the list of users.
      assert.response.error(await request.api(auth, 'get', 'user/list'), denied);

      // Cannot add a new user.
      assert.response.error(await request.api(auth, 'post', 'user/add').send({
        username: 'BR0kEN',
        group: 'viewer',
      }), denied);

      // Cannot delete a user.
      assert.response.error(await request.api(auth, 'delete', 'user/delete/BR0kEN'), denied);

      // Able to refresh own access token.
      assert.response.auth(await request.api(auth, 'post', 'user/auth/refresh').send({
        grant_type: 'refresh_token',
        refresh_token: auth.body.refresh_token,
      }));

      // Unable to refresh a non-existing token.
      assert.response.error(await request.api(auth, 'post', 'user/auth/refresh').send({
        grant_type: 'refresh_token',
        refresh_token: auth.body.refresh_token,
      }), {
        httpCode: 401,
        errorId: 910,
        error: 'Refresh token not found',
      });

      // Access token was refreshed, therefore it's not possible to access
      // the resources with an old one anymore.
      assert.response.error(await request.api(auth, 'get', 'droplet/list'), {
        httpCode: 401,
        errorId: 908,
        error: 'Access token not found',
      });
    });

    it(`should not be able to get a QR code for setting up an authenticating application as "${group}"`, async () => {
      const auth = await request.auth(users[group]);

      assert.response.auth(auth);
      assert.response.error(await request.api(auth, 'get', `user/auth/setup/${users[group]}`), denied);
    });
  });

  it('should be able to access the "user/*" endpoints as "owner"', async () => {
    const addFailingSuites = [
      {
        httpCode: 400,
        errorId: 913,
        error: 'The request body must contain "group" and "username"',
        data: {},
      },
      {
        httpCode: 400,
        errorId: 913,
        error: 'The request body must contain "group" and "username"',
        data: {
          group: 'bla',
        },
      },
      {
        httpCode: 400,
        errorId: 913,
        error: 'The request body must contain "group" and "username"',
        data: {
          username: 'bla',
        },
      },
      {
        httpCode: 400,
        errorId: 914,
        error: 'Username is already taken',
        data: users.owner,
      },
      {
        httpCode: 403,
        errorId: 906,
        error: 'The system cannot have multiple owners',
        data: {
          username: users.owner + '-1',
          group: users.owner.group,
        },
      },
      {
        httpCode: 400,
        errorId: 905,
        error: 'The group is unknown',
        data: {
          username: users.owner + '-1',
          group: users.owner.group + '-1',
        },
      },
    ];

    const validNewUser = {
      username: 'test-user-12',
      group: 'viewer',
    };

    // Authenticate an owner.
    const auth = await request.auth(users.owner);

    // Ensure the user is authenticated.
    assert.response.auth(auth);
    // Can see a list of users.
    assert.response.list(await request.api(auth, 'get', 'user/list'));

    // Various unsuccessful attempts to add a user.
    for (let i = 0; i < addFailingSuites.length; i++) {
      assert.response.error(await request
        .api(auth, 'post', 'user/add')
        .send(addFailingSuites[i].data), addFailingSuites[i]
      );
    }

    // Add a new user.
    let updatedList = await request.api(auth, 'post', 'user/add').send(validNewUser);

    // The updated list should be returned.
    assert.response.list(updatedList);

    // Newly created user is appended to the list.
    ['username', 'group'].forEach(property => {
      // Take the last one.
      updatedList.body[updatedList.body.length - 1].should.have
        .property(property)
        .eql(validNewUser[property]);
    });

    // Delete a non-existing user.
    assert.response.error(await request.api(auth, 'delete', 'user/delete/bla'), {
      httpCode: 400,
      errorId: 903,
      error: 'User not found',
    });

    // Remove a user created the moment before.
    updatedList = await request.api(auth, 'delete', `user/delete/${validNewUser.username}`);
    // The list of users is returned.
    assert.response.list(updatedList);

    // Iterate the list of users trying to find removed account.
    updatedList.body.forEach(user => {
      if (user.username === validNewUser.username) {
        throw new Error('User was not removed!');
      }
    });
  });

  it('should be able to get a QR code for setting up an authenticating application as "owner"', async () => {
    const auth = await request.auth(users.owner);

    assert.response.auth(auth);
    assert.response.auth.setup(await request.api(auth, 'get', `user/auth/setup/${users.owner}`));
  });

  it('should be able to revoke an access token for yourself', async () => {
    // Authenticate a user with least permissions.
    const auth = await request.auth(users.viewer);
    // Revoke an access for yourself.
    assert.response.auth.revoke(await request.api(auth, 'delete', `user/auth/revoke/${users.viewer}`));
  });

  it('should not be able to revoke an access token for others', async () => {
    // Authenticate a manager.
    const auth = await request.auth(users.manager);

    // Cannot revoke an access for a viewer.
    assert.response.error(await request.api(auth, 'delete', `user/auth/revoke/${users.viewer}`), {
      httpCode: 401,
      errorId: 904,
      error: 'Only system owner can revoke access for others',
    });
  });

  it('should be able to revoke an access token for others as "owner"', async () => {
    // Authenticate an owner.
    const auth = await request.auth(users.owner);

    assert.response.auth(auth);
    assert.response.auth.revoke(await request.api(auth, 'delete', `user/auth/revoke/${users.viewer}`));
    assert.response.auth.revoke(await request.api(auth, 'delete', `user/auth/revoke/${users.manager}`));
  });

  it('should be able to see the list of droplets and be not able to do something with them as "viewer"', async () => {
    const auth = await request.auth(users.viewer);

    assert.response.auth(auth);
    assert.response.list(await request.api(auth, 'get', 'droplet/list'));
    assert.response.error(await request.api(auth, 'post', 'droplet/add'), denied);
    assert.response.error(await request.api(auth, 'patch', 'droplet/stop/bla'), denied);
    assert.response.error(await request.api(auth, 'patch', 'droplet/start/bla'), denied);
    assert.response.error(await request.api(auth, 'patch', 'droplet/restart/bla'), denied);
    assert.response.error(await request.api(auth, 'delete', 'droplet/delete/bla'), denied);
  });

  ['manager', 'owner'].forEach(group => {
    it(`should be able to manage droplets as "${group}"`, async () => {
      const auth = await request.auth(users[group]);
      let currentLength = -1;
      let droplets = [];
      let droplet = null;

      const doer = async (method, route) => {
        const list = await request.api(auth, method, route);

        assert.response.list(list);

        return list;
      };

      const compare = async (method, route, dropletsIncrement = 0, portsNumber = 3, statusRegexp = /^Up \d+/) => {
        droplets = await doer(method, route);
        // Ensure new droplet is in the list.
        droplets.body.should.have.length(currentLength + dropletsIncrement);
        // Update current number of droplets.
        currentLength = droplets.body.length;
        droplet = droplets.body[currentLength - 1];

        if (null !== portsNumber) {
          Object.keys(droplet.ports).should.have.length(portsNumber);
          droplet.status.should.match(statusRegexp);
        }
      };

      // Ensure a user is authorized.
      assert.response.auth(auth);

      // Get initial list of droplets.
      droplets = await doer('get', 'droplet/list');
      // Store the initial number of droplets.
      currentLength = droplets.body.length;

      await compare('post', 'droplet/add', 1);
      await compare('patch', `droplet/stop/${droplet.name}`, 0, 0, /^Exited \(0\)/);
      await compare('patch', `droplet/start/${droplet.name}`);
      await compare('patch', `droplet/restart/${droplet.name}`);
      await compare('delete', `droplet/delete/${droplet.name}`, -1, null);
    });
  });

  it('should not be able to do something with not existing droplet as "manager"', async () => {
    const auth = await request.auth(users.manager);
    const commonError = {
      httpCode: 400,
      errorId: 900,
      error: 'Error response from daemon: No such container: bla',
    };

    const startError = Object.assign({}, commonError);
    startError.error += '\nError: failed to start containers: bla';

    assert.response.auth(auth);
    assert.response.error(await request.api(auth, 'patch', 'droplet/stop/bla'), commonError);
    assert.response.error(await request.api(auth, 'patch', 'droplet/start/bla'), startError);
    assert.response.error(await request.api(auth, 'patch', 'droplet/restart/bla'), commonError);
    assert.response.error(await request.api(auth, 'delete', 'droplet/delete/bla'), commonError);
  });
});
