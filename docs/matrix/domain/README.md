# Host domain

[Host](../host) is internet-accessible resource. Let's imagine that its IP is `a.b.c.d`. In this case an entry in [inventory](../../ansible/inventory) file will looks like:

```ini
[our-host]
a.b.c.d ansible_user=root ansible_ssh_private_key_file=~/.ssh/id_rsa
```

TODO
