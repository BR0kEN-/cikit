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

## Before you begin

Physical server must be provisioned with a superuser which has no-password access for `sudo` (e.g. `your_user ALL=(ALL) NOPASSWD:ALL` entry in `/etc/sudoers`). So, make sure the user is properly configured if you have set value for `ansible_user`, different from `root`, in your [inventory](../docs/ansible/inventory).

The recommendation is to run the provisioning using `root` user. But you may choose. Besides, please MAKE SURE you took care about security!

Recommended (will work as untrusted connection):

- [SSL certificates](vars/ssl.yml#L3). Use trusted certificates to provide secure connection.

Optional (passwords will be generated automatically if not set):

- [Name and password for user to run `VBoxWeb` service](vars/phpvirtualbox.yml#L10-L11). This user is permitted to connect via SSH.
- [Password for `admin` user for VirtualBox GUI](vars/phpvirtualbox.yml#L7-L8). CRUD operations for users and virtual machines.

**You can easily omit setting the passwords (especially if you can't invent secure ones).** In this case they'll be automatically generated, used and saved locally in `credentials/HOSTNAME/phpvirtualbox_users_system_pass` and `credentials/HOSTNAME/phpvirtualbox_users_gui_pass`. At any further reprovisioning they'll be looked up from those files, so you may not worry their changed.

Not recommended (general credentials - not good for each virtual machine):

- [Basic HTTP authentication](vars/nginx.yml#L4-L12). Not recommended to set it up for the whole server - better to do this for every particular virtual machine.

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
