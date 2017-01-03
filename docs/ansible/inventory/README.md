# Ansible Inventory

The [inventory](../../inventory) file stores an information about hosts, managed by **CIKit**.

To specify a new host you have to use the following lines:

```ini
[host-name]
cikit01.example.com ansible_user=root ansible_port=2201
```

- `host-name` - is a human-readable name which you have to use in `--limit` parameter for `cikit` utility.
- `cikit01.example.com` - hostname you want to provision.
- `ansible_user` - username for accessing the host via SSH.
- `ansible_port` - number of port for accessing the host via SSH.

The next SSH command illustrates an example above:

```shell
ssh -p2201 root@cikit01.example.com
```

*Assumed that you have an access to the host via key pair.*

All other SSH-related variables can be found here: http://docs.ansible.com/ansible/intro_inventory.html#list-of-behavioral-inventory-parameters
