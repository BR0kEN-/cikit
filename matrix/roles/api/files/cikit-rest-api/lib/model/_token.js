module.exports = name => app => {
  const mongoose = app.get('mongoose');
  const model = new mongoose.Schema({
    userId: {
      type: String,
      required: true,
    },
    token: {
      type: String,
      unique: true,
      required: true,
    },
    created: {
      type: Date,
      default: Date.now,
    },
  });

  model.methods.toString = function () {
    return this.token;
  };

  return mongoose.model(name, model);
};
