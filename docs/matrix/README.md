# Matrix

Let's describe structure and technologies. First of all, we need to get acquainted with two basic terms: `host` and `droplet`.

- `host` - [machine for storing and controlling virtual machines](host);
- `droplet` - virtual machine, located on the `host`.

As many droplets as needed can be created on a host machine (depending on hardware configuration, of course).

Host machine operates by a minimal set of software:

- Docker
- Nginx

Each droplet has its own private network, which is forwarded from a host. Nginx is listening for the `80<NN>` and `443<NN>` ports on a host and forwards connection inside the droplets, to the usual ports (without `<NN>` suffix). Using the `22<NN>` port you can SSH to the droplet.

*`<NN>` is a serial number of the particular droplet which is generated automatically.*

That's all! And it's cool! Each virtual server may be additionally provisioned by main `cikit` tool to convert it to CI server.

## Before you begin

Remember that host machine must be publicly accessible via internet. Otherwise you will be required to manually configure forwarding to the following ports: `22<NN>`, `80<NN>` and `443<NN>`.

Host server must be provisioned with a superuser which has no-password access for `sudo` (e.g. `your_user ALL=(ALL) NOPASSWD:ALL` entry in `/etc/sudoers`). So, make sure the user is properly configured if you have set value for `ansible_user`, different from `root`, in your [inventory](../ansible/inventory).

The recommendation is to run the provisioning using `root` user. But you may choose. Beside of that, please make sure you took care about security!

Recommended (will work as untrusted connection):

- [SSL certificates](../../matrix/vars/ssl.yml#L3). Use trusted certificates to provide secure connection.

Not recommended (general credentials - not good for each virtual machine):

- [Basic HTTP authentication](../../matrix/vars/nginx.yml#L4-L12). Not recommended to set it up for the whole server - better to do this for every particular virtual machine.

## Usage

Add your own host inside the `inventory` file and run the following command:

```shell
./cikit matrix/matrix.yml --limit=<HOSTNAME>
```

### Add trusted SSL certificate

The `*.crt` and `*.key` files must be inside of the `/path/to/directory/`. They will be copied and Nginx will start using them immediately.

```shell
./cikit matrix/matrix.yml --limit=<HOSTNAME> --tags=ssl --ssl-src=/path/to/directory/ --restart=nginx
```

## Management

Below is described a manual how to work with a matrix of virtual servers.

### Get the list of droplets

```shell
./cikit matrix/matrix.yml --limit=<HOSTNAME> --tags=vm --droplet-list
```

The result of execution will be similar to:

```shell
ok: [matrix1] => {
    "output": [
        "632fa30ababe        solita/ubuntu-systemd   \"/bin/bash -c 'exe...\"   About an hour ago   Up About an hour    0.0.0.0:2201->22/tcp, 127.0.0.1:8001->80/tcp, 127.0.0.1:44301->443/tcp   cikit01"
    ]
}
```

### Create a new droplet

```shell
./cikit matrix/matrix.yml --limit=<HOSTNAME> --tags=vm --droplet-add
```

Initially, you will get created a `cikit01`, the next will be `cikit02`, the third one - `cikit03` and so on.

### Manage a droplet

```shell
./cikit matrix/matrix.yml --limit=<HOSTNAME> --tags=vm --droplet-[delete|stop|start|restart]=<NAME>
```
