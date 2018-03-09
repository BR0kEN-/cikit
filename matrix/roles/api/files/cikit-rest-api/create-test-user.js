const app = require('./lib/app');
const mongoose = app.get('mongoose');
const config = app.get('config');
const log = app.get('log');

const User = app.get('User');
const Client = app.get('Client');
const AccessToken = app.get('AccessToken');
const RefreshToken = app.get('RefreshToken');

User.remove({}, () => {
  const user = new User({
    username: config.get('default:user:username'),
    password: config.get('default:user:password')
  });

  user.save((error, user) => {
    if (error) {
      return log.error(error);
    }

    log.info('New user - %s:%s', user.username, user.password);
  });
});

Client.remove({}, () => {
  const client = new Client({
    name: config.get('default:client:name'),
    clientId: config.get('default:client:clientId'),
    clientSecret: config.get('default:client:clientSecret')
  });

  client.save((error, client) => {
    if (error) {
      return log.error(error);
    }

    log.info('New client - %s:%s', client.clientId, client.clientSecret);
  });
});

AccessToken.remove({}, error => error && log.error(error));
RefreshToken.remove({}, error => error && log.error(error));

setTimeout(() => mongoose.disconnect(), 3000);
