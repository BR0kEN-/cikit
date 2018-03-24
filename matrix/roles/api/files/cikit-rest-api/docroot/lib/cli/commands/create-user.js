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
 * @type {{username: {String}, recreate: {Bool}, group: {String}}}
 */
const args = parser.parseArgs();

(async () => {
  let user = await app.managers.user.getByName(args.username);

  if (null !== user) {
    if (args.recreate) {
      app.log.debug('An account for %s will be re-created. This action will invalidate the belonged secret key.', args.username);

      await user.remove();
      // Set to "null" as a user needs to be created.
      user = null;
    }
    else {
      app.log.debug('The "access" and "refresh" tokens for %s will be revoked.', args.username);
    }
  }
  else {
    app.log.debug('An account for %s will be created.', args.username);
  }

  if (null === user) {
    user = await app.managers.user.create(args.username, args.group);
  }

  await user.revokeAccess();

  // eslint-disable-next-line no-console
  console.info(
    `
      Open base64-encoded PNG in a browser and scan QR code by your authenticator
      app (e.g. Google Authenticator) or input the "secret" code manually to add
      an integration.

      Keep this data private or remove them at all if an integration is added to
      an authenticating app. Later, having an access to the service via SSH, you
      will be able to recreate 2FA secret key.

      Secret key: ${user.secret}
      Barcode: ${await user.generateBarcode()}
    `
  );

  await app.db.disconnect();
})();

// setTimeout(() => app.db.disconnect(), 1500);
