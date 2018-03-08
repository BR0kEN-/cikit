module.exports = app => {
  const mongoose = app.get('mongoose');

  return mongoose.model('Client', new mongoose.Schema({
    name: {
      type: String,
      unique: true,
      required: true,
    },
    clientId: {
      type: String,
      unique: true,
      required: true,
    },
    clientSecret: {
      type: String,
      required: true,
    },
  }));
};
