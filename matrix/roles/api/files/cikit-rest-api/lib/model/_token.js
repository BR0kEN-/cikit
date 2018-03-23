module.exports = name => app => {
  const schema = new app.mongoose.Schema({
    user: {
      type: app.mongoose.Schema.Types.ObjectId,
      ref: 'User',
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

  schema
    .path('user')
    .required(true);

  return app.mongoose.model(name, schema);
};
