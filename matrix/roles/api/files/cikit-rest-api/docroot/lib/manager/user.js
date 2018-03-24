module.exports = app => {
  /**
   * @namespace Application.managers.user
   */
  return {
    /**
     * @param {Object} [conditions=null]
     *   The list of conditions.
     * @param {Object} [projection=null]
     *   The list of properties to return (http://bit.ly/1HotzBo).
     *
     * @return {Promise.<Mongoose.Model[]>|null}
     *   A list of users.
     */
    async getMultiple(conditions = null, projection = null) {
      return await app.db.models.User.find(conditions, projection);
    },

    /**
     * @param {Object} conditions
     *   The conditions to match.
     *
     * @return {Promise.<Mongoose.Model>|null}
     *   The user's object.
     */
    async get(conditions) {
      return await app.db.models.User.findOne(conditions);
    },

    /**
     * @param {String} username
     *   The name of a user.
     *
     * @return {Promise.<Mongoose.Model>|null}
     *   The user's object.
     */
    async getByName(username) {
      return await this.get({username});
    },

    /**
     * @param {String} username
     *   The name of a user.
     * @param {String} group
     *   The name of a user's group.
     *
     * @return {Promise.<Object>}
     *   The user's object.
     */
    async create(username, group) {
      const user = await this.get({group, username: {$ne: username}});

      if (null !== user && user.isOwner()) {
        throw new app.errors.RuntimeError('The system cannot have multiple owners', 403, 'user_owner_exists');
      }

      return new app.db.models.User({username, group}).save();
    },
  };
};
