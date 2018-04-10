---
title: Hosting project on Platform.sh
permalink: /documentation/workflow/platformsh/
---

Hosting platforms differ from each other and we have to take some actions before being compatible with [Platform.sh](https://platform.sh/).

## Add Platform.sh CLI

- Open the `<PROJECT_DIR>/.cikit/roles/cikit-project/meta/main.yml` and add`cikit-platformsh-cli` role under the `dependencies`:

  ```yaml
  dependencies:
    - role: cikit-platformsh-cli
      tags: ["platformsh"]
  ```
- Create `.platform.app.yaml` and `.platform` directory within `<PROJECT_DIR>`, following the [official documentation](https://docs.platform.sh/configuration/app-containers.html).

## Configure hosting

- Generate an [API token](https://docs.platform.sh/gettingstarted/cli/api-tokens.html) or use an existing one.
- Create the `.platform.app.json` inside `<PROJECT_DIR>`.
  ```json
  {
    "id": "PROJECT_ID",
    "token": "AUTHENTICATION_TOKEN"
  }
  ```
  Replace the `PROJECT_ID` and `AUTHENTICATION_TOKEN` by the actual data. Commit this file to **private repositories** only or just keep it locally.
  {: .notice--warning}

## Inject Platform.sh configuration

- Open `<PROJECT_DIR>/scripts/vars/main.yml` and add the {% raw %}`platformsh: "{{ lookup('file', '../.platform.app.json') | from_json }}"`{% endraw %} variable.
- Provision VM/CI server as usual.
- Read [how to grab a database from one of Platform.sh environments](../../project/mysql-import-strategies#platformsh) using SQL workflow.
