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
- Use similar contents of the `.environment` file in the root of your project since it'll be added to the `/etc/profile`. The `$PLATFORM_APP_DIR` is available on Platform.sh but in a local VM we have to set it manually. This little trick does the job.

  ```bash
  # This is the Platform.sh-oriented file.
  # - https://docs.platform.sh/development/variables.html#shell-variables
  # CIKit support for this file.
  # - https://cikit.tools/documentation/workflow/platformsh/#inject-platformsh-configuration
  #
  # Statements in this file will be executed (sourced) by the shell in SSH
  # sessions, in deploy hooks, in cron jobs, and in the application's runtime
  # environment.
  : "${PLATFORM_APP_DIR:="$CIKIT_PROJECT_DIR"}"

  export PATH="$PLATFORM_APP_DIR/bin:$PATH"
  ```
