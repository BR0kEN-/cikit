# Host domain

[Host](../host) is an internet-accessible resource. Let's imagine that its IP is `1.2.3.4`. In this case an entry in [inventory](../../ansible/inventory) file will looks like:

```ini
matrix1 ansible_host=1.2.3.4 ansible_user=root ansible_ssh_private_key_file=~/.ssh/id_rsa
```

Having this bare minimum *you're able* to provision the matrix, but **using an IP instead of domain name is not supported and may lead to unpredictable issues**.

For instance, logic inside assumes you have the domain names in inventory to setting up the hostnames and Jenkins URLs.

## What to do if I don't have a domain?

Use `hosts` file of your OS and/or DNS within local network (requires network administration knowledge).

Example of `/etc/hosts`:

```ini
1.2.3.4  matrix1.cikit
```

Having this, replace the `1.2.3.4` in [inventory](../../ansible/inventory) by `matrix1.cikit`.

After creating VM on the matrix, new entry for it in [inventory](../../ansible/inventory) will looks like:

```ini
cikit<NN>.matrix1 ansible_host=cikit<NN>.matrix1.cikit [other arguments...]
```

But remember that your domain is just local alias of IP, so you are required to modify the `hosts` file after every droplet creation.

```ini
1.2.3.4  matrix1.cikit cikit<NN>.matrix1.cikit
```

This will make the `cikit<NN>` droplet to work using alias on the same IP and resolve port forwarding within the matrix.

## Okay, what is `<NN>`?

It is just a serial number of VM. First will have `01`, second - `02` etc. [General Matrix documentation](../../matrix) contains more information.
