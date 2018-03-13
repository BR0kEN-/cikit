## Authentication flow

- Define base URL for sending queries.

  ```bash
  export CIKIT_MATRIX_REST_API_BASE_URL="http://ipu1.loc:1337/api/v1"
  ```

- Use temporary code from an authenticating app to send the request for obtaining an access token.

  ```bash
  curl "$CIKIT_MATRIX_REST_API_BASE_URL/auth/otp" \
    -X POST \
    -H 'Content-Type: application/json' \
    -d '{"code": "CODE_FROM_AUTH_APP", "username": "BR0kEN"}'
  ```

  Response sample:

  ```json
  {
    "token_type": "Bearer",
    "expires_in": 7200,
    "access_token": "5e11d712066b99a9868888ec253c1979da9dc8f9823831262139f235ab9d64c3",
    "refresh_token": "3ead5fbb1a4e3953f855d84b304d96b08d10a83cad38ebc544832f2125293f2b"
  }
  ```

- Add `Authorization: Bearer: ACCESS_TOKEN` header or `{"access_token": "ACCESS_TOKEN"}` to body for every request to an API. If you'll get `401`, then the token is expired and you have to send a request for its refreshment (better flow is to store the `expires_in` in your implementation and check its validity before sending a request to an API).

  ```bash
  curl "$CIKIT_MATRIX_REST_API_BASE_URL/auth/token" \
    -X POST \
    -H 'Content-Type: application/json' \
    -d '{"grant_type", "refresh_token", "refresh_token": "REFRESH_TOKEN"}'
  ```

  Response sample:

  ```json
  {
    "token_type": "Bearer",
    "expires_in": 7200,
    "access_token": "b8bd12dd0c97ae280a9ff3bd1be39c9c5dea3de7cf949082d5edf9f6f2e945ef",
    "refresh_token": "7ee3085e08e4cac476bd533abb15523d80d3099a5c4d2c22410d5a719ad70dc6"
  }
  ```