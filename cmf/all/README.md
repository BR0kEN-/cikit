# CIKit

## Statistic

If you'd like to see the contribution to the project of each team member - clone this repository and execute:

```shell
curl -LSs https://goo.gl/iQGjeM | sh
```

## Installation

Dependencies that should be on your computer (host):

- [Ansible](http://docs.ansible.com/ansible/intro_installation.html#latest-releases-via-pip)
- [Vagrant](https://www.vagrantup.com/downloads.html)
- [VirtualBox](https://www.virtualbox.org/wiki/Downloads)

### Windows

Run the [install.bat](https://github.com/BR0kEN-/cikit/blob/master/tests/cygwin/install.bat) (save and double-click) to have all necessary software installed on **Windows** host (*OS will be automatically restarted if don't have PowerShell 3 to complete a setup of it*). Then open a Cygwin (which will be installed automatically by the mentioned script) and follow the below instructions.

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

Add the `ANSIBLE_ARGS="--tags=php-stack,solr"` environment variable with desired tags before the command to do a partial provisioning.

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
