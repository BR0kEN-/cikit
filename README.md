# Continuous Integration Kit

**CIKit** - [Ansible](https://github.com/ansible/ansible)-based system for deploying development environments or clusters of them. With this tool everyone is able to create virtual machine (based on [Vagrant](https://github.com/mitchellh/vagrant) using VirtualBox provider) for particular team member, matrix of continuous integration servers or single CI server for project(s).

*Currently based on [Ubuntu 16.04 LTS (64 bit)](docs/vagrant/box)*.

```ascii
 ██████╗ ██╗    ██╗  ██╗ ██╗ ████████╗
██╔════╝ ██║    ██║ ██╔╝ ██║ ╚══██╔══╝
██║      ██║    █████╔╝  ██║    ██║   
██║      ██║    ██╔═██╗  ██║    ██║   
╚██████╗ ██║    ██║  ██╗ ██║    ██║   
 ╚═════╝ ╚═╝    ╚═╝  ╚═╝ ╚═╝    ╚═╝   
```

## Main possibilities

- Isolated, by virtual machine, LAMP stack for web development.
- Continuous integration scripts for Drupal 7, 8 and WordPress (you can your own by the need).
- [Matrix of virtual servers (in Docker containers)](docs/matrix).
- Jenkins on each CI server with an ability to manage several projects.
- CI strategy via GitHub (builds of PRs).

## Documentation

Global project documentation [available here](docs#documentation).

## Slack

All communications are available in our Slack account at https://cikit.slack.com

## Quick Start

- Install the **CIKit** (only once).

  ```shell
  curl -LSs https://raw.githubusercontent.com/BR0kEN-/cikit/issues/45/install.sh | sh
  ```

- Create CIKit-based project.

  ```shell
  cikit init --project=<NAME> [--cmf=drupal|wordpress] [--version=7.56|8.3.x-dev|4.8.1] [--without-sources]
  ```

  The `--without-sources` option affects CMF sources downloading. Use it if you want to create an empty project (CIKit-structured package with empty `docroot` directory, where you have to store the source code of Drupal/WordPress/whatever).

- Build a virtual machine for local development.

  ```shell
  vagrant up --provision
  ```

  Build website inside of a ready VM (will be accessible at `https://<PROJECT-NAME>.dev`).

  ```shell
  vagrant ssh
  cikit reinstall
  ```

- Add your host credentials to the [inventory](docs/ansible/inventory) file (not needed to continue without remote CI server).

- Provision remote CI server.

  ```
  cikit provision --limit=<HOST>
  ```

Last two steps are not mandatory. You can omit them and use CIKit as local environment for development.

## Provisioning variations

**Provision** - is an operation that configure CI server or virtual machine and install necessary software there to convert it to unit for development.

Initially (at the very first time) you are required to run full provisioning to build the environment correctly. After that you may decide to reinstall or reset configuration of some part of it. This is feasible thanks to separation of the provisioning.

Get the list of components to provision:

```shell
cikit provision --list-tags
```

Run provisioning of specific component (CI server):

```shell
ANSIBLE_ARGS="--tags=COMPONENT" cikit provision
```

Run provisioning of specific component (virtual machine):

```shell
ANSIBLE_ARGS="--tags=COMPONENT" vagrant provision
```

## The power of `cikit` utility

Run with custom inventory file:

```shell
ANSIBLE_INVENTORY="/path/to/inventory" cikit
```

Run with custom set of arguments:

```shell
ANSIBLE_ARGS="-vvvv" cikit
```

## Dependencies

To have CIKit works you must have the following software installed on your host.

### All

|Name|Version|
|:---|:---|
|Vagrant|1.9+|
|Ansible|2.2+|
|VirtualBox|5.1+|

### Windows

|Name|Version|Reason|
|:---|:---|:---|
|PowerShell|3.0+|https://github.com/mitchellh/vagrant/issues/8611|
