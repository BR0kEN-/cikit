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

const {ArgumentParser} = require('argparse');
const app = require('../../app');
const parser = new ArgumentParser({
  addHelp: true,
});

parser.addArgument(['-u', '--username'], {
  help: 'The name to create an account with.',
  required: true,
});

parser.addArgument(['-g', '--group'], {
  help: 'The name of a group a user belong to.',
  choices: app.config.get('security:user:groups'),
  required: true,
});

parser.addArgument(['-r', '--recreate'], {
  help: 'Regenerate the user and tokens.',
  action: 'storeTrue',
});

/**
 * @namespace
 * @type {{username: {String}, recreate: {Bool}, group: {String}}}
 */
const args = parser.parseArgs();

app.managers.user
  .ensureUser(args.username, args.group, args.recreate)
  .then(async user => {
    // eslint-disable-next-line no-console
    console.log({
      message:
        'Open base64-encoded PNG in a browser and scan QR code by your authenticator' +
        'app (e.g. Google Authenticator) or input the "secret" code manually to add' +
        'an integration.' +
        '\n\n' +
        'Keep this data private or remove them at all if an integration is added to' +
        'an authenticating app. Later, having an access to the service via SSH, you' +
        'will be able to recreate 2FA secret key.',
      group: user.group,
      secret: user.secret,
      barcode: await user.generateBarcode(),
    });
  });

setTimeout(() => app.db.disconnect(), 1500);
