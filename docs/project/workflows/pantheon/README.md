# Hosting project on Pantheon

- Open the `<PROJECT_DIR>/.cikit/roles/cikit-project/meta/main.yml` and add the `cikit-pantheon-terminus` role under the `dependencies`:

  ```yaml
  dependencies:
    - role: cikit-pantheon-terminus
      tags: ["terminus"]
  ```

- Open the `<PROJECT_DIR>/scripts/vars/main.yml` and add the `pantheon` variable:

  ```yaml
  pantheon:
    # The ID could be found in your Pantheon account.
    site_id: THE_ID_OF_A_SITE
  ```

- Provision VM/CI server as usual.
- Login on VM/CI server using the next command (read more how to create tokens at https://dashboard.pantheon.io/user#account/tokens/create/terminus):

  ```bash
  terminus auth:login --machine-token=GENERATED_TOKEN --email=YOUR_ACCOUNT_EMAIL
  ```

- Read [how to grab the database from one of the Pantheon environments](../../mysql-import-strategies#pantheon) while using SQL workflow.
