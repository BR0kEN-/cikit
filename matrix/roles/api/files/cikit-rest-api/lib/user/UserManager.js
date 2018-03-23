module.exports = app => {
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
    async getUsers(conditions = null, projection = null) {
      return await app.mongoose.models.User.find(conditions, projection);
    },

    /**
     * @param {Object} conditions
     *   The conditions to match.
     *
     * @return {Promise.<Mongoose.Model>|null}
     *   The user's object.
     */
    async getUser(conditions) {
      return await app.mongoose.models.User.findOne(conditions);
    },

    /**
     * @param {String} username
     *   The name of a user.
     *
     * @return {Promise.<Mongoose.Model>|null}
     *   The user's object.
     */
    async getUserByName(username) {
      return await this.getUser({username});
    },

    /**
     * @param {Object|String} user
     *   The user's object or the name of a group.
     *
     * @return {Boolean}
     *   A state whether the user is a system owner.
     */
    isOwner(user) {
      return 'owner' === ('string' === typeof user ? user : user.group);
    },

    /**
     * @param {String} username
     *   The name of a user.
     * @param {String} group
     *   The name of a user's group.
     * @param {Boolean} recreate
     *   An indicator for removing an existing user and creating it again. This
     *   can be useful in order to regenerate TOTP secret.
     *
     * @return {Object}
     *   The user's object.
     */
    async ensureUser(username, group, recreate = false) {
      const createUser = async () => {
        if (this.isOwner(group) && null !== await this.getUser({group, username: {$ne: username}})) {
          throw new app.errors.RuntimeError('The system cannot have multiple owners', 403, 'user_owner_exists');
        }

        return new app.mongoose.models.User({username, group}).save();
      };

      const user = await this
        .getUserByName(username)
        .then(async user => {
          if (recreate && null !== user) {
            app.log.debug('An account for %s will be re-created. This action will invalidate the belonged secret key.', username);
            await user.remove();

            return createUser();
          }

          if (null !== user) {
            app.log.debug('The "access" and "refresh" tokens for %s will be revoked.', username);

            return user;
          }

          app.log.debug('An account for %s will be created.', username);

          return createUser();
        });

      await user.revokeAccess();

      return user;
    },
  };
};
