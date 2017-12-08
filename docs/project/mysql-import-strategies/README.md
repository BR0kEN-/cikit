# MySQL import strategies

When you're using SQL workflow and importing a project database from the remote then it might happen that you'll need some customization of that process. Import strategies - are the scenarios on how to download the database you need.

## Strategies

CIKit ships with some predefined strategies which you can review below. Note, that each of them requires some configuration of the `databases` variable at `<PROJECT_DIR>/scripts/vars/main.yml`.

The `databases` variable - is a dictionary, where the key is an unique identifier of a dataset and the value must contain a dictionary with at least two of three keys: `name` and `source`.

### Default

The default strategy helps you to fetch the database via SSH.

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

The value for `from` could be CIKit droplet where the project is hosted. Its name can be found in `<PROJECT_DIR>/.cikit/credentials/<MATRIX_DIR>/<DROPLET_DIR>`. If you have a similar path, then `from` should contain the name of directories, divided by the dot: `<MATRIX_DIR>.<DROPLET_DIR>` (e.g. `matrix1.cikit01` for the `<PROJECT_DIR>/.cikit/credentials/matrix1/cikit01`).

Also, you can the host aliases, defined by the [host manager](../../host). Run `cikit host/list` on your computer and use one of the available aliases of hosts that command will print. Refer to the documentation if there are no hosts and you're willing to add some.

### Pantheon

Create and fetch database snapshots from Pantheon.

```yaml
pantheon:
  # This value will be used by Terminus.
  site_id: THE_ID_OF_A_PROJECT

databases:
  default:
    # Form an unique name of the database (e.g. "wordpress_PROJECT_NAME_default").
    name: "{{ cmf }}_{{ project | replace('-', '_') }}_{{ build_id | default(env) }}"
    # The import strategy.
    strategy: pantheon
    source:
      # Database name on remote host.
      db: "{{ 'dev' if 'default' == env else env }}"
```

The configuration for the `pantheon` strategy is a bit simpler. Just add the `strategy` property having the `pantheon` as a value and specify the `db` key only under the `source` dictionary.

To read more about the `pantheon` variable please refer to the documentation of [Pantheon](../../project/workflows/pantheon) workflow.

## Custom

You either can define a custom strategy by creating the `STRATEGY_NAME.yml` file at `<PROJECT_DIR>/scripts/tasks/database/import-strategies`. The `STRATEGY_NAME` then should be used as a value for the `strategy` key at the dataset of the `databases` dictionary.

## Notes

The strategy will be used only when you don't have the local copy of a database downloaded and placed at the `<PROJECT_DIR>/backup/<DB_NAME>`. To force its usage (database fetching) remove the database file manually.
