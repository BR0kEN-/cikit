module.exports = name => app => {
  const mongoose = app.get('mongoose');

  return mongoose.model(name, new mongoose.Schema({
    userId: {
      type: String,
      required: true,
    },
    clientId: {
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
  }));
};
