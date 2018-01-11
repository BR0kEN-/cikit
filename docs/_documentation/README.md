---
title: Documentation
permalink: /documentation/
---

**CIKit** is a package that supported on **Linux**, **macOS**, **Windows 10** and should be installed once for further use as a command line utility.

## Dependencies

The installation process on **Windows 10** is a bit complicated and must be done by [following the special instructions](install-on-wsl) that will install Vagrant and Ansible automatically. Please, do not try to proceed, relying on your knowledge, even if you're 100% sure how to deal with it. The WSL is in active development and things changes quite often. There were many hours spent on investigations for providing a working step-by-step tutorial.
{: .notice--warning}

|Name|Version|
|:---|:---|
|[Ansible](https://github.com/ansible/ansible)|2.4+|
|[Vagrant](https://github.com/hashicorp/vagrant)|1.9.5+|
|[VirtualBox](https://www.virtualbox.org)|5.1+|

## Installation

Run the script to install the package and consider the `--no-requirements-check` option that allows you to ignore missing dependencies (CIKit will operate in a limited mode or won't operate at all).

```bash
curl -LSs https://raw.githubusercontent.com/BR0kEN-/cikit/master/install.sh | bash
```

*Package will be located at* `/usr/local/share/cikit`.

## Update

```bash
cikit self-update
```

Available options:

- `--force` to clear the changes that have been locally made and get the latest codebase without conflicts.
- `--version` to specify the branch or tag within the repository to get the codebase from.
- `--repository` to specify the repository of the package that could be, for instance, your fork of the main project.
- `--skip-fetch` to not pull the latest codebase and just ensure that all migrations to a new version were correctly applied.

Example:

```bash
cikit self-update \
  --force \
  --version=issues/52 \
  --repository=https://github.com/gajdamaka/cikit.git
```

## Create a project

Use what is needed instead of the `PROJECT` and remember that the directory with a name in the option will be created in the location of command execution.

```bash
cikit init --project=PROJECT
cd PROJECT
```

Available options:

- `--cmf` for downloading the `wordpress` or `drupal`.
- `--version` for specifying an exact version (e.g. `7.56`, `8.5.x-dev`, `4.9.1` etc.) of CMF to download.
- `--without-sources` affects CMF downloading. Use it for creating a project with an empty `docroot`, where you can place whatever you want.

## Build a virtual machine for local development

```bash
vagrant up --provision
```

Install a website inside of VM that will be accessible at `https://PROJECT.loc`.

```bash
vagrant ssh
cikit reinstall
exit
```

## Build a remote continuous integration server

You can skip this step if you are interested just in a local environment without provisioning a CI server for the project.

```
cikit provision --limit=HOSTNAME
```

Read more about the `HOSTNAME` in a section about the [hosts manager](hosts-manager).

## Commands quick reference

The information below is a good reminder of commands to run (order preserved).

```bash
cikit init --project=PROJECT
cd PROJECT

# Define the credentials for the matrix of droplets.
cikit host/add --alias=matrix1 --domain=example.com [--ssh-key=~/.ssh/id_rsa] [--ssh-user=root] [--ssh-port=22]
# Create the matrix itself.
cikit matrix/provision --limit=matrix1
# Create first droplet - "cikit01".
cikit matrix/droplet --limit=matrix1 --droplet-add

# Provision remote CI server.
#cikit provision --limit=matrix1.cikit01
# Add project to existing, already provisioned, server.
#cikit jenkins-job --limit=matrix1.cikit01

# Provision local virtual machine.
vagrant up --provision
```

## Useful tips

### SSH keys protection

In a case of creating a CI server or when putting a project to an existing one, always remember that you're copying SSH key-pair to the project tree! They are needed to provision a droplet but **you're bringing a serious risk to lose the data on that droplet if the private key leaked**. Share secret data only via private channels (private Git repository, for instance).

### Provision using tags

Provision is an operation that configures CI server or VM and installs necessary software there to convert it to a unit for development.

At the very first time you are required to run full provisioning to build an environment correctly. After that you may decide to reinstall or reset configuration of some part of it. This is feasible thanks to the separation of a provisioning.

Get the list of available components:

```bash
CIKIT_LIST_TAGS=true cikit provision
```

Run provisioning of a specific component (CI server):

```bash
CIKIT_TAGS="COMPONENT1,COMPONENT2" cikit provision
```

Run provisioning of a specific component (VM):

```bash
CIKIT_TAGS="COMPONENT1,COMPONENT2" vagrant provision
```
