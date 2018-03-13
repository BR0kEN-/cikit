let {generateTotpSecret, isTotpTokenValid} = require('../auth/functions');

module.exports = app => {
  const mongoose = app.get('mongoose');
  const totp = app.get('config').get('security:totp');

  generateTotpSecret = generateTotpSecret.bind(undefined, totp);
  isTotpTokenValid = isTotpTokenValid.bind(undefined, totp);

  const model = new mongoose.Schema({
    username: {
      type: String,
      unique: true,
      required: true,
    },
    secret: {
      type: String,
      unique: true,
      required: true,
      default: generateTotpSecret,
    },
    created: {
      type: Date,
      default: Date.now,
    },
    group: {
      type: String,
      default: 'viewer',
      required: true,
    },
  });

  model.methods.isTotpValid = function (code) {
    return isTotpTokenValid(this.secret, code);
  };

  model
    .virtual('userId')
    .get(function () {
      return this.id;
    });

  return mongoose.model('User', model);
};
