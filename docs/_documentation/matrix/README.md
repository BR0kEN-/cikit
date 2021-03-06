---
title: Matrix
permalink: /documentation/matrix/
---

Let's describe structure and technologies. First of all, we need to get acquainted with two basic terms: `host` and `droplet`.

- `host` - machine for storing and controlling droplets;
- `droplet` - virtual machine (Docker container that behaves as a VM), located on `host`.

## Requirements to host

- A machine with **Ubuntu 16.04 LTS (64 bit)** on board (can be a VM with enabled VT-x).
- Installed `openssh-server` and configured for key-based access.
- A `root` or no-password `sudo` user.

Host machine operates by a minimal set of software:

- Docker
- Nginx

Each droplet has its own private network, which is forwarded from a host. Nginx is listening for the `80<NN>` and `443<NN>` ports on a host and forwards connection inside the droplets, to the usual ports (without `<NN>` suffix). Using the `22<NN>` port you can SSH to the droplet.

`<NN>` is a serial number of the particular droplet which is generated automatically.
{: .notice--info}

That's all! And it's cool! Each virtual server may be additionally provisioned by main `cikit` tool to convert it to CI server.

## Before you begin

Remember that host machine must be publicly accessible via internet. Otherwise you will be required to manually configure forwarding to the following ports: `22<NN>`, `80<NN>` and `443<NN>`.

Host server must be provisioned with a superuser which should have no-password access to `sudo` (e.g. `your_user ALL=(ALL) NOPASSWD:ALL` entry in `/etc/sudoers`). So, make sure the user is properly configured if you have set a value for the `--ssh-user`, different from `root`, when defining a [host](../hosts-manager).

The recommendation is to run the provisioning using `root` user. But you may choose. Beside of that, please make sure you took care about security!

Recommended (will work as untrusted connection):

- [SSL certificates](https://github.com/BR0kEN-/cikit/tree/master/matrix/vars/ssl.yml#L3). Use trusted certificates to provide secure connection.

Not recommended (general credentials - not good for each virtual machine):

- [Basic HTTP authentication](https://github.com/BR0kEN-/cikit/tree/master/matrix/vars/nginx.yml#L4-L9). Not recommended to set it up for the whole server - better to do this for every particular virtual machine.

## Usage

[Define a new host](../hosts-manager) and run the next command:

```shell
cikit matrix/provision --limit=HOSTNAME
```

### Add trusted SSL certificate

The `*.crt` and `*.key` files must be inside of the `/path/to/directory/`. They will be copied and Nginx will start using them immediately.

```shell
CIKIT_TAGS="ssl" cikit matrix/provision --limit=HOSTNAME --ssl-src=/path/to/directory/ --restart=nginx
```

## Management

Below is described a manual how to work with a matrix of virtual servers.

### Get the list of droplets

```shell
cikit matrix/droplet --limit=HOSTNAME --droplet-list
```

The result of execution will be similar to:

```shell
ok: [matrix1] => {
    "output": [
        "632fa30ababe        br0ken/ubuntu-systemd   \"/bin/bash -c 'exe...\"   About an hour ago   Up About an hour    0.0.0.0:2201->22/tcp, 127.0.0.1:8001->80/tcp, 127.0.0.1:44301->443/tcp   cikit01"
    ]
}
```

### Create a new droplet

```shell
cikit matrix/droplet --limit=HOSTNAME --droplet-add
```

Initially, you will get created a `cikit01`, the next will be `cikit02`, the third one - `cikit03` and so on.

### Manage a droplet

```shell
cikit matrix/droplet --limit=HOSTNAME --droplet-[delete|stop|start|restart]=<NAME>
```
