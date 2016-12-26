# Ansible Inventory

The [inventory](../../inventory) file stores the information about the hosts managed by **CIKit**.

To specify a new host you have to use the following lines:

```ini
[host-name]
cikit01.example.com ansible_user=root ansible_port=2201
```

- `host-name` - is a human-readable name which you have to use in `--limit` parameter for `cikit` utility.
- `cikit01.example.com` - could be any domain you want to provision.
- `ansible_user` - username for accessing the domain via SSH.
- `ansible_port` - number of port for accessing the domain via SSH.

All other SSH-related variables could be found here: http://docs.ansible.com/ansible/intro_inventory.html#list-of-behavioral-inventory-parameters
