let {generateTotpSecret, isTotpCodeValid} = require('../auth/functions');

module.exports = app => {
  const totp = app.config.get('security:totp');

  generateTotpSecret = generateTotpSecret.bind(undefined, totp);
  isTotpCodeValid = isTotpCodeValid.bind(undefined, totp);

  const schema = new app.mongoose.Schema({
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
      enum: Object.keys(app.config.get('security:user:groups')),
      default: 'viewer',
      required: true,
    },
  });

  schema.methods.isTotpValid = function (code) {
    return isTotpCodeValid(this.secret, code);
  };

  schema
    .virtual('userId')
    .get(function () {
      return this.id;
    });

  return app.mongoose.model('User', schema);
};
