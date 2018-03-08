module.exports = app => {
  const mongoose = app.get('mongoose');
  const crypto = app.get('crypto');
  const User = new mongoose.Schema({
    username: {
      type: String,
      unique: true,
      required: true,
    },
    hashedPassword: {
      type: String,
      required: true,
    },
    salt: {
      type: String,
      required: true,
    },
    created: {
      type: Date,
      default: Date.now,
    },
  });

  User.methods.encryptPassword = function (password) {
    return crypto.pbkdf2Sync(password, this.salt, 10000, 512, 'sha512').toString('hex');
  };

  User.methods.checkPassword = function (password) {
    return this.encryptPassword(password) === this.hashedPassword;
  };

  User
    .virtual('userId')
    .get(function () {
      return this.id;
    });

  User
    .virtual('password')
    .set(function (password) {
      this._plainPassword = password;
      this.salt = crypto.randomBytes(128).toString('hex');
      this.hashedPassword = this.encryptPassword(password);
    })
    .get(function () {
      return this._plainPassword;
    });

  return mongoose.model('User', User);
};
