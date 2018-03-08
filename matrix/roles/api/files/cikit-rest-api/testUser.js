var log = require('./lib/log')(module);
var db = require('./lib/db/mongoose');
var config = require('./lib/config');

var User = require('./lib/model/user');
var Client = require('./lib/model/client');
var AccessToken = require('./lib/model/accessToken');
var RefreshToken = require('./lib/model/refreshToken');

User.remove({}, function (error) {
  var user = new User({
    username: config.get('default:user:username'),
    password: config.get('default:user:password')
  });

  user.save(function (error, user) {
    if (error) {
      return log.error(error);
    }

    log.info('New user - %s:%s', user.username, user.password);
  });
});

Client.remove({}, function (error) {
  var client = new Client({
    name: config.get('default:client:name'),
    clientId: config.get('default:client:clientId'),
    clientSecret: config.get('default:client:clientSecret')
  });

  client.save(function (error, client) {
    if (error) {
        return log.error(error);
    }

    log.info('New client - %s:%s', client.clientId, client.clientSecret);
  });
});

AccessToken.remove({}, function (error) {
  if (error) {
    return log.error(error);
  }
});

RefreshToken.remove({}, function (error) {
  if (error) {
    return log.error(error);
  }
});

setTimeout(function () {
  db.disconnect();
}, 3000);
