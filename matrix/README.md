# Matrix

With this tool you able to create own matrix with virtual servers.

Let's describe a structure and technologies. First of all, we need to get acquainted with two basic terms: `host` and `droplet`.

- `host` - is a physical computer (server);
- `droplet` - is a virtual machine, located on the `host`.

As much as needed droplets can be created on a host machine (depending on hardware configuration, of course).

Host machine operates only by minimal set of software:

- VirtualBox
- NGINX
- PHP
- phpVirtualBox

Every droplet has it own private network, which forwarded to a host. For example, you have 10 virtual server. Each of them forwards three ports: `80<NN>`, `443<NN>` and `22<NN>` (`<NN>` - is a serial number of a droplet). NGINX is listening `80<NN>` and `443<NN>` ports on a host and forwards connection inside of droplets. `80<NN>` forwards to 80, `443<NN>` - to 443. `22<NN>` forwards to 22, for SSH connections.

That's all! And that's cool! Every virtual server can be additionally provisioned by main `cikit` tool to convert it to CI server.

## Usage

Add your own host inside of `inventory` file and run the following command:

```shell
./cikit matrix/matrix.yml --limit=<HOSTNAME>
```

New droplets (VMs) will be based on an image, which is assume as [base](vars/virtualmachine.yml#L13) for the matrix.

### Add trusted SSL certificate

Inside of the `/path/to/directory/` two files must be located: `*.crt` and `*.key`. They are will be copied and NGINX start to use them immediately.

```shell
./cikit matrix/matrix.yml --limit=<HOSTNAME> --tags=ssl --ssl-src=/path/to/directory/ --restart=nginx
```

## Management

You able to choose two ways to manage your virtual machines: using [Ansible](docs/droplet/ANSIBLE.md) or [UI of PHP Virtual Box](docs/droplet/UI.md).

## To do

- [ ] Allow to add SSH keys to a droplet on creation phase
- [ ] Reuse roles from Matrix in CIKit (`nginx`, `ssl`)
- [ ] Set hostname for every new droplet
