---
title: Hosting project on Pantheon
permalink: /docs/project/pantheon-workflow/
---

- Open the `<PROJECT_DIR>/.cikit/roles/cikit-project/meta/main.yml` and add the `cikit-pantheon-terminus` role under the `dependencies`:

  ```yaml
  dependencies:
    - role: cikit-pantheon-terminus
      tags: ["terminus"]
  ```

- Create the `pantheon.yml` file in the `<PROJECT_DIR>` following the [official documentation](https://pantheon.io/docs/pantheon-yml). Add custom properties: `site`, `user.token` (read more how to create tokens at https://dashboard.pantheon.io/user#account/tokens/create/terminus) and `user.email`. Example:

  ```yaml
  # Custom properties.
  site: dp844aa6-8f67-45a1-9dea-a2335347c0bd
  # This user will be used by Terminus.
  user:
    email: sergii.bondarenko@cikit.tools
    token: mAcRd9ZiUo1GPyPyWpiX2Ey-lKNyZzaWUYYGGpwlvylPn

  # Pantheon-related properties.
  # https://pantheon.io/docs/pantheon-yml
  api_version: 1
  php_version: 5.6
  web_docroot: true
  drush_version: 8
  ```

- Open the `<PROJECT_DIR>/scripts/vars/main.yml` and add the `pantheon: "{{ lookup('file', '../pantheon.yml') | from_yaml }}"` variable.
- Provision VM/CI server as usual.
- Read [how to grab the database from one of the Pantheon environments](../../mysql-import-strategies#pantheon) while using SQL workflow.
