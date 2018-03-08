---
title: MySQL import strategies
permalink: /documentation/project/mysql-import-strategies/
description: A subset of ways to import a MySQL database from various locations.
---

When you're using SQL workflow and importing a project database from the remote then it might happen that you'll need some customization of that process. Import strategies - are the scenarios on how to download the database you need.

## Strategies

CIKit ships with some predefined strategies which you can review below. Note, that each of them requires some configuration of the `databases` variable at `<PROJECT_DIR>/scripts/vars/main.yml`.

The `databases` variable - is a dictionary, where the key is an unique identifier of a dataset and the value must contain a dictionary with at least two of three keys: `name` and `source`.

### Default

The default strategy helps you to fetch a database via SSH.

{% raw %}
```yaml
databases:
  default:
    # Form an unique name of the database (e.g. "drupal_PROJECT_NAME_demo").
    name: "{{ cmf }}_{{ project | replace('-', '_') }}_{{ build_id | default(env) }}"
    source:
      # Database name on remote host.
      db: "mydbname"
      # Host name, from the inventory file, where to make a snapshot.
      from: "matrix1.cikit01"
#      # Path to directory to place database snapshot on remote host ("/var/www/backup" by default).
#      dir: ""
#      # MySQL port on remote host ("3306" by default).
#      port: ""
#      # MySQL host on remote host ("localhost" by default).
#      host: ""
#      # MySQL user on remote host ("{{ mysql.user }}" by default).
#      user: ""
#      # MySQL password on remote host ("{{ mysql.pass }}" by default).
#      pass: ""
```
{% endraw %}

The value for `from` could be CIKit droplet where the project is hosted. Its name can be found in `<PROJECT_DIR>/.cikit/credentials/<MATRIX_DIR>/<DROPLET_DIR>`. If you have a similar path, then `from` should contain the name of directories, divided by the dot: `<MATRIX_DIR>.<DROPLET_DIR>` (e.g. `matrix1.cikit01` for the `<PROJECT_DIR>/.cikit/credentials/matrix1/cikit01`).

Also, you can use host aliases, defined by the [host manager](../../hosts-manager). Run `cikit host/list` *on your computer* and use one of the available aliases of hosts that command will print. Refer to the documentation if there are no hosts and you're willing to add some.

### Pantheon

Create and fetch database snapshots from [Pantheon](https://pantheon.io).

{% raw %}
```yaml
pantheon: "{{ lookup('file', '../pantheon.yml') | from_yaml }}"

databases:
  default:
    # Form an unique name of the database (e.g. "wordpress_PROJECT_NAME_default").
    name: "{{ cmf }}_{{ project | replace('-', '_') }}_{{ build_id | default(env) }}"
    # The import strategy.
    strategy: pantheon
    source:
      # In this case it's an environment (not exact DB name) to take DB from.
      db: "{{ 'dev' if 'default' == env else env }}"
```
{% endraw %}

The configuration for the `pantheon` strategy is a bit simpler. Just add the `strategy` property having the `pantheon` as a value and specify the `db` key under the `source` dictionary.

Refer to the documentation of the [Pantheon](../../workflow/pantheon) workflow to read more about the `pantheon` variable.

### Platform.sh

Create and fetch database snapshots from [Platform.sh](https://platform.sh).

The configuration of the strategy for this hosting platform is similar to [Pantheon](#pantheon) except value for `strategy` key that must be `platformsh` and `pantheon` variable that must not be existent in favor of `platformsh`.

{% raw %}
```yaml
platformsh: "{{ lookup('file', '../.platform.app.json') | from_json }}"

databases:
  default:
    # Form an unique name of the database (e.g. "wordpress_PROJECT_NAME_default").
    name: "{{ cmf }}_{{ project | replace('-', '_') }}_{{ build_id | default(env) }}"
    # The import strategy.
    strategy: platformsh
    source:
      # In this case it's an environment (not exact DB name) to take DB from.
      db: "{{ 'dev' if 'default' == env else env }}"
```
{% endraw %}

Refer to the documentation of the [Platform.sh](../../workflow/platformsh) workflow to read more about the `platformsh` variable.

### Custom

You either can define a custom strategy by creating the `STRATEGY_NAME.yml` at `<PROJECT_DIR>/scripts/tasks/database/import-strategies`. The `STRATEGY_NAME` then should be used as a value for the `strategy` key at the dataset of the `databases` dictionary.

## Notes

- The strategy will be used only when you don't have the local copy of a database downloaded and placed at the `<PROJECT_DIR>/backup/<DB_NAME>`. To force its usage (database fetching) remove the database file manually.
