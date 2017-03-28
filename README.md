# Continuous Integration Kit

**CIKit** is [Ansible](https://github.com/ansible/ansible) based system for web application development. You are able to deploy a local web-server based on [Vagrant](https://github.com/mitchellh/vagrant) and/or remote one with this tool.

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
- Multi CMS/CMF support (`Drupal` and `WordPress` at the moment). To introduce a new one, you just have to add pre-configurations to `cmf/<NAME>/<MAJOR_VERSION>` and make sure that system is downloadable as an archive.
- Opportunity to keep multiple projects on the same CI server.
- Triggering builds via comments in pull requests.
- Applying [sniffers](docs/project/sniffers) to control code quality.
- Midnight server cleaning :)

## Documentation

Global project documentation [available here](docs).

## Slack

All communications are available in our Slack account at https://cikit.slack.com

## Quick Start

- Get the **CIKit**.

  ```shell
  git clone https://github.com/BR0kEN-/cikit.git
  cd cikit
  ```

- Create CIKit-based project.

  ```shell
  ./cikit repository --project=<NAME> [--cmf=drupal|wordpress] [--version=7.53|8.3.x-dev|4.6.1] [--without-sources]
  git init
  git add .
  git commit -m 'Init of CIKit project'
  ```

  The `--without-sources` option for project creation task affects CMF sources downloading. Use it if you want to create an empty project (CIKit-structured package with empty `docroot` directory, where you have to store the source code of Drupal/WordPress/whatever).

- Build virtual machine for local development.

  ```shell
  vagrant up --provision
  ```

  Build website inside of ready VM (will be accessible at `https://<NAME>.dev`).

  ```shell
  vagrant ssh
  cikit reinstall
  ```

- Add your host credentials to the [inventory](docs/ansible/inventory) file.

- Provision remote CI server.

  ```
  cd <NAME>
  ./cikit provisioning/provision --project=<NAME> [--limit=<HOST>]
  ```

Last two steps are not mandatory. You can omit them and use CIKit as local environment for development.

## Provisioning variations

**Provision** - is an operation that configure CI server or virtual machine and install necessary software there to convert it to unit for development.

Initially (at the very first time) you are required to run full provisioning to build the environment correctly. After that you may decide to reinstall or reset configuration of some part of it. This is feasible thanks to separation of the provisioning.

Get the list of components to provision:

```shell
./cikit provisioning/provision --list-tags
```

Run provisioning of specific component (CI server):

```shell
ANSIBLE_ARGS="--tags=COMPONENT" ./cikit provisioning/provision
```

Run provisioning of specific component (virtual machine):

```shell
ANSIBLE_ARGS="--tags=COMPONENT" vagrant provision
```

## The power of `cikit` utility

Run with custom inventory file:

```shell
ANSIBLE_INVENTORY="/path/to/inventory" ./cikit
```

Run with custom set of arguments:

```shell
ANSIBLE_ARGS="-vvvv" ./cikit
```

By default, `cikit` - is a global utility (only inside of VM) which looks for a project in `/var/www/`. But if you specify a playbook outside of this directory, then working folder will be the path of this playbook.

## Dependencies

You should have the following software on your host machine:

| Name        | Version |
| ----------- | ------- |
| Vagrant     | 1.7+    |
| Ansible     | 2.1+    |
| VirtualBox  | 4.0+    |
