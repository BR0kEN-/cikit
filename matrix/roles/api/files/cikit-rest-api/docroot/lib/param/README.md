# Route parameter loaders

This directory is automatically scanned for the route parameter loaders. In a case of having the `/api/v1/user/:user` route, you can create the `user.js` in this directory and handle the input value.

## Example

```javascript
module.exports = async (username, app) => {
  const user = await app.managers.user.getByName(username);

  if (null !== user) {
    return user;
  }

  throw new app.errors.RuntimeError('User not found', 400, 'user_not_found');
};
```

The returned value will be added to the request's `payload` object (i.e. `request.payload.user`).
