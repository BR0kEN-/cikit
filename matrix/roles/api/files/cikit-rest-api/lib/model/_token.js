module.exports = name => app => {
  const schema = new app.mongoose.Schema({
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

  return app.mongoose.model(name, schema);
};
