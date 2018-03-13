'use strict';

/**
 * @example
 * // Create a new user or remove "access" and "refresh" OAuth tokens if
 * // a user already exists.
 * node ./lib/cli/commands/create-user.js -u BR0kEN -g owner
 *
 * // Re-create a secret for 2FA and remove "access" and "refresh" OAuth
 * // tokens if a user already exists. A new user will be created if not
 * // exist.
 * node ./lib/cli/commands/create-user.js -u BR0kEN -r -g
 */

const ArgumentParser = require('argparse').ArgumentParser;
const app = require('../../app');
const parser = new ArgumentParser({
  addHelp: true,
});

parser.addArgument(['-u', '--username'], {
  help: 'The name to create an account with.',
  required: true,
});

parser.addArgument(['-g', '--group'], {
  help: 'The names of groups the user belongs to.',
  choices: app.get('config').get('security:user:groups'),
  required: true,
});

parser.addArgument(['-r', '--recreate'], {
  help: 'Remove the user and the client.',
  action: 'storeTrue',
});

/**
 * @namespace
 * @type {{username: {String}, recreate: {Bool}, group: {String}}}
 */
const args = parser.parseArgs();

require('../../user/manager')(app, args.username, args.group, args.recreate);

setTimeout(() => app.get('mongoose').disconnect(), 1500);
