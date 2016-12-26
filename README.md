# Continuous Integration Kit

**CIKit** is [Ansible](https://github.com/ansible/ansible) based system for web application environment development. You are able to deploy a local web-server based on [Vagrant](https://github.com/mitchellh/vagrant) and/or remote one with this tool.

The power of the system - simplicity. The provisioning is the same whether it's local or remote machine, except of a logic for installing additional software on remote machine (Jenkins, for example), but it's also quite simple (just `when: not vagrant` as a condition for Ansible tasks).

*Currently based on `Ubuntu 14.04 LTS (64bit)`*.

```ascii
 ██████╗ ██╗    ██╗  ██╗ ██╗ ████████╗
██╔════╝ ██║    ██║ ██╔╝ ██║ ╚══██╔══╝
██║      ██║    █████╔╝  ██║    ██║   
██║      ██║    ██╔═██╗  ██║    ██║   
╚██████╗ ██║    ██║  ██╗ ██║    ██║   
 ╚═════╝ ╚═╝    ╚═╝  ╚═╝ ╚═╝    ╚═╝   
```

## Main possibilities

- [Create matrix of virtual servers (droplets).](matrix)
- Automated builds for each commit in a pull request on GitHub (private repositories are supported).
- Multi CMS/CMF support. You just need to put pre-configurations to `cmf/<NAME>/<MAJOR_VERSION>` and ensure that core files may be downloaded as an archive for adding the support of a new one.
- Opportunity to keep multiple projects on the same CI server.
- Triggering builds via comments in pull requests.
- Applying [sniffers](docs/project/sniffers) to control code quality.
- Midnight server cleaning :)

## Documentation

Global project documentation [available here](docs).

## Quick Start

- Add your host credentials to the [inventory](docs/ansible/inventory) file.
- `./cikit repository --project=<NAME> [--cmf=drupal] [--version=7.53] [--without-sources]`
- `./cikit provision --project=<NAME> [--limit=<HOST>]`

The `--without-sources` option for `repository` task is affected on downloading CMF sources. If you want to create an empty project - use it.

### Examples

#### Drupal 7

```shell
./cikit repository --project=test
```

#### Drupal 8

```shell
./cikit repository --project=test --version=8.3.x-dev
```

#### WordPress 4

```shell
./cikit repository --project=test --cmf=wordpress --version=4.6.1
```

**Note**: these commands should be executed on your host, not inside the virtual machine!

## Variations

Currently `provision.yml` playbook is powered with tags, so you can run only part of it.

```shell
./cikit provision --tags=TAGNAME
```

- php
- misc
- sass
- security
- nginx
- selenium
- memcache
- php-stack
- solr
- nodejs
- jenkins
- composer
- sniffers
- apache
- mysql
- swap
- ssl

You are also able to specify tags for provisioning Vagrant:

```shell
ANSIBLE_ARGS="--tags=TAGNAME" vagrant provision
```

As you can see, any set of arguments can be passed for `ansible-playbook` command.

## The power of `cikit` utility

Run with custom inventory file:

```shell
ANSIBLE_INVENTORY="/path/to/inventory" ./cikit
```

Run with custom set of arguments:

```shell
ANSIBLE_ARGS="-vvvv" ./cikit
```

By default, `cikit` is a global utility which looks for a project in `/var/www/`. But if you specify a playbook outside of this directory, then working folder is the path of this playbook.

## Dependencies

You should have the following software on your host machine:

| Name        | Version |
| ----------- | ------- |
| Vagrant     | 1.7+    |
| Ansible     | 2.0+    |
| VirtualBox  | 4.0+    |
