let {generateTotpSecret, isTotpTokenValid} = require('../auth/functions');

module.exports = app => {
  const mongoose = app.get('mongoose');
  const config = app.get('config');
  const totp = config.get('security:totp');

  generateTotpSecret = generateTotpSecret.bind(undefined, totp);
  isTotpTokenValid = isTotpTokenValid.bind(undefined, totp);

  const schema = new mongoose.Schema({
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
      enum: Object.keys(config.get('security:user:groups')),
      default: 'viewer',
      required: true,
    },
  });

  schema.methods.isTotpValid = function (code) {
    return isTotpTokenValid(this.secret, code);
  };

  schema
    .virtual('userId')
    .get(function () {
      return this.id;
    });

  return mongoose.model('User', schema);
};
