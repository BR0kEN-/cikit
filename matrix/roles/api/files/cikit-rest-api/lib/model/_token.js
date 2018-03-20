module.exports = name => app => {
  const mongoose = app.get('mongoose');
  const schema = new mongoose.Schema({
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

  schema.methods.toString = function () {
    return this.token;
  };

  return mongoose.model(name, schema);
};
