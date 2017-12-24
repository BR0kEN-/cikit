# CIKit

## Installation

Dependencies that should be on your computer (host):

- [Ansible](http://docs.ansible.com/ansible/intro_installation.html#latest-releases-via-pip)
- [Vagrant](https://www.vagrantup.com/downloads.html)
- [VirtualBox](https://www.virtualbox.org/wiki/Downloads)

### Windows with WSL

Read and follow the [instructions to prepare your host for operating with CIKit](https://github.com/BR0kEN-/cikit/blob/master/docs/vagrant/wsl).

## Usage

### Running a VM

```shell
vagrant up
vagrant ssh
```

### Provision a VM

```shell
vagrant provision
```

Add the `CIKIT_TAGS="php-stack,solr"` environment variable with desired tags before the command to do a partial provisioning.

### Application actions

All actions ought to be executed inside of VM.

Reinstall a web application.

```shell
cikit reinstall
```

Run various tools (PHPCS, HTMLCS, SCSS & JS lints etc.) for checking your codebase.

```shell
cikit sniffers
```

Run tests.

```shell
cikit tests
```

**Note:** the first argument to `cikit` utility is Ansible playbook from the `/var/www/scripts/`. By default, there are `reinstall`, `sniffers` and `tests` but you may invent yours.
