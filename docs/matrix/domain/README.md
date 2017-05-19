# Host domain

[Host](../host) is an internet-accessible resource. Let's imagine that its IP is `1.2.3.4`. In this case an entry in [inventory](../../ansible/inventory) file will looks like:

```ini
matrix1 ansible_host=1.2.3.4 ansible_user=root ansible_ssh_private_key_file=~/.ssh/id_rsa
```

Having this bare minimum *you're able* to provision the matrix, but **using an IP instead of domain name is not supported and will lead to unpredictable issues**.

For instance, logic inside assumes you have the domain names in inventory for setting up the hostnames. Also, to use continuous integration flow, external services (like Github) *must* be able to reach your host back via internet.

## What to do if I don't have a domain?

Well, you can use `hosts` file within your OS and/or DNS server for local network. Also, be ready that all ports are opened for local network only. So, not having a domain, you are required to have strong knowledge of networks administration and good undersanding of CIKit architecture, because its needs to be reconfigured.

*Just refuse this idea, seriously!*
