# Solr

Be aware that Solr - is not a regular service which can be used thru `System V` initialization scripts (like `sudo service solr restart`).

By default it's configured to be operable by its own user - `solr` - with home directory at `/opt/solr`. Data directory with schema, cores and another configurations located at `/var/solr`.

## Usage

Execute `sudo runuser -l solr -c "solr"` to see the list of available operations.

### Common examples

Check the status, stop, start and/or restart server.

```shell
sudo runuser -l solr -c "solr [status|stop|start|restart]"
```

### Warning

You may simplify the entire command to execute to `sudo solr` and suppress warning using `-force` option but it's definitely not recommended to run search server that way.
