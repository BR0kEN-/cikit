# Continuous Integration Kit

**CIKit** - is [Ansible](https://github.com/ansible/ansible) based system for deployment environment for web application development. With this tool you able to deploy local web-server based on [Vagrant](https://github.com/mitchellh/vagrant) and/or remote one.

The power of the system - simplicity. All provisioning is the same for local and remote machines, except logic for installing additional software on remote (Jenkins, for example), but it quite simple too (just `when: not vagrant` as condition for Ansible tasks).

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
- Automated builds for every commit in a pull request on GitHub (private repositories supported).
- Multi CMS/CMF support. To add support of a new one, you just need to put pre-configurations to `cmf/<NAME>/<MAJOR_VERSION>` and ensure that core files can be downloaded as an archive.
- Opportunity to keep multiple projects on the same CI server.
- Triggering builds via comments in pull requests.
- Midnight server cleaning :)

## Documentation

Global project documentation [available here](docs).

## Quick Start

- Add your host credentials to the `inventory` file.
- `./cikit repository --project=<NAME> [--cmf=drupal] [--version=7.53] [--without-sources]`
- `./cikit provision --project=<NAME> [--limit=<HOST>]`

The `--without-sources` option for `repository` task affected on downloading CMF sources. If you want to create an empty project - use it.

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

#### Add Jenkins project to existing CI server

```shell
./cikit jenkins-job --project=test [--limit=<HOST>]
```

**Note**: these commands should be executed on your host, not inside of virtual machine!

## Variations

Currently `provision.yml` playbook powered with tags, so you can run only part of it.

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

For provisioning Vagrant you also able to specify tags:

```shell
ANSIBLE_ARGS="--tags=TAGNAME" vagrant provision
```

As you see, any set of arguments can be passed for `ansible-playbook` command.

## The power of `cikit` utility

Run with custom inventory file:

```shell
ANSIBLE_INVENTORY="/path/to/inventory" ./cikit
```

Run with custom set of arguments:

```shell
ANSIBLE_ARGS="-vvvv" ./cikit
```

By default, `cikit` - is a global utility which looks for a project in `/var/www/`. But, if you specify a playbook outside of this directory, then working folder will be the path of this playbook.

## Dependencies

On your host machine you should have the following software:

| Name        | Version |
| ----------- | ------- |
| Vagrant     | 1.7+    |
| Ansible     | 2.0+    |
| VirtualBox  | 4.0+    |
