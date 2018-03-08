module.exports = app => {
  const mongoose = app.get('mongoose');

  return mongoose.model('RefreshToken', new mongoose.Schema({
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
