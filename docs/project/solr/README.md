# Solr

Be aware that Solr - is not a regular service which can be used thru `System V` initialization scripts (like `sudo service solr restart`).

By default it's configured to be operable by its own user - `solr` - with home directory at `/opt/solr`. Data directory with schema, cores and another configurations located at `/var/solr`.

## Usage

Execute `sudo solr` to see the list of available operations.

### Common examples

Check the status, stop, start and/or restart server.

```shell
sudo solr [status|stop|start|restart]
```
