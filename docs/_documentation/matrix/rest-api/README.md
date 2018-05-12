---
title: REST API
permalink: /documentation/matrix/rest-api/
description: REST API to control droplets remotely.
---

The API is built on [Express.js](http://expressjs.com), uses [MongoDB](http://mongoosejs.com) and fully covered by [unit and functional tests](https://coveralls.io/github/BR0kEN-/cikit-rest-api) that sweeps Matrix functionalities too.

You may create multiple users that will use two-factor authentication for accessing and managing the Matrix. There are available three [roles](https://github.com/BR0kEN-/cikit-rest-api#user-groups): `owner` that is able to manage user accounts and whole Matrix, `manager` that can do everything with droplets and a `viewer`, available for checking the list and statuses of droplets.

## API

The specifications and available endpoints listed in the [documentation](https://github.com/BR0kEN-/cikit-rest-api#api).

## Deployment

Read the [instructions](https://github.com/BR0kEN-/cikit-rest-api#production) for deploying the API to new or existing matrix.

## Local development

The API is implemented as a separate project and its documentation for testing and further development available [here](https://github.com/BR0kEN-/cikit-rest-api#local-or-testing-environment).

## Future plans

As the next step, CIKit will get the React application that will use the API and allow everyone to manage the Matrix via nice'n'fast user interface from a desktop or a smartphone.
