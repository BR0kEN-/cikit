---
title: Project (re-)installation
permalink: /documentation/project/reinstall/
---

The `cikit reinstall` command (re-)installs a project, executing a set of tasks. Every project has `scripts/vars/main.yml` configuration where some important variables are stored.

## env

A machine name of an environment, configuration of which to use during (re-)installation (saying simpler - the name of a file in `scripts/vars/environments/*.yml`).

```yaml
env: default
```

Use `--env=NAME` as CLI option to change the value temporary.
{: .notice--info}

## sql_workflow

A state whether a project is on SQL workflow (when a project is not installing from scratch but incrementally imports a database snapshot and perform the upgrade path).

```yaml
sql_workflow: no
```

Use `--sql-workflow` as CLI option to temporary set the value to `yes`. Disabling via the option is not permitted.
{: .notice--info}

## env_vars

An additional dictionary of environment variables to use during for Bash, Drush, and WP CLI.

```yaml
env_vars:
  APP_ENV: "{% raw %}{{ env }}{% endraw %}"
```

## environments/default.yml

A set of configurations to apply during (re-)installation. Can be changed by modifying the `env: NAME` in `main.yml` or by the `--env=NAME` CLI option.

### Drupal

When `--cmf=drupal` was used to `cikit init` then the file will contain the `drupal` dictionary.

```yaml
---
commands:
  bash: []
  drush:
#    - vset: ["file_temporary_path", "{{ tmproot }}"]
#    - vset: ["error_level", "2"]
#    - cset: ["system.file", "path.temporary", "{{ tmproot }}"]
#    - cset: ["system.logging", "error_level", "verbose"]
      en: ["dblog", "field_ui"]

drupal:
  # Data for super-admin (UID 1).
  user:
    name: admin
    pass: propeople
```

### WordPress

When `--cmf=wordpress` was used to `cikit init` then the file will contain the `wordpress` dictionary.

```yaml
commands:
  bash: []
  wp-cli:
    - name: "Checking theme status"
      theme: ["status"]
    - name: "Installing environment-specific plugins"
      plugin: ["install", "plugin-name"]
    - plugin: ["uninstall", "plugin-name1", "plugin-name2"]

wordpress:
  user:
    name: admin
    pass: propeople
```

### Custom

When `--cmf=CUSTOM` was used to `cikit init` then the file will contain what you've placed in its stub. Read about [integrating CMS or framework](/documentation/project/cmf-integration/) to know more.

## Commands

### Bash

Every item of the `bash` list in `commands` dictionary may have up to 3 keys, but only one is required. Example:

```yaml
commands:
  bash:
    - name: "Running deploy routines"
      run: ".platform/hooks/hook.sh deploy"
      if: "{% raw %}{{ sql_workflow }}{% endraw %}"
```

Here are some rules you have to follow:

- The `name` and `if` keys are optional for every item.
- The value of `if` must be evaluated first, i.e. `{% raw %}{{ variable }}{% endraw %}`.
- If `name` is missing the `Running a Bash command` is used.
- The `run` key must contain an inline script or path to file.

Every script in `run` key will be executed by `bash` in the `scripts` directory of a project (do not forget to `cd` if you need another directory).

### Drush

Every item of the `drush` list in `commands` dictionary may have up to 3 keys, but only one is required. Example:

```yaml
commands:
  bash:
    - name: "Enabling environment-specific modules"
      en: ["dblog", "field_ui"]
    - name: "Import configuration"
      cim: ~
      if: "{% raw %}{{ not sql_workflow }}{% endraw %}"
```

Here are some rules you have to follow:

- The `name` and `if` keys are optional for every item.
- The value in `if` must be evaluated first, i.e. `{% raw %}{{ variable }}{% endraw %}`.
- If `name` is missing the `Running a Drush command` is used.
- The key that is not the `name` or `if` is a name of Drush command.
- The `-y` option is added by default to every command.
- The arguments may be a list, string or none.

### WP CLI

Every item of the `wp-cli` list in `commands` dictionary may have up to 3 keys, but only one is required. Example:

```yaml
commands:
  wp-cli:
    - name: "Checking theme status"
      theme: ["status"]
    - name: "Installing environment-specific plugins"
      plugin: ["install", "plugin-name"]
    - plugin: ["uninstall", "plugin-name1", "plugin-name2"]
```

Here are some rules you have to follow:

- The `name` and `if` keys are optional for every item.
- The value in `if` must be evaluated first, i.e. `{% raw %}{{ variable }}{% endraw %}`.
- If `name` is missing the `Running a WP command` is used.
- The key that is not the `name` or `if` is a WP command.
- The `--allow-root` option is added by default to every command.
- The arguments may be a list, string or none.

## Notes

- This documentation is valid unless you weren't changing the implementation shipped out of the box. CIKit cannot provide a unique script for every system and every project, so that's why you have all those scripts in your project. Feel free to modify everything you want.
