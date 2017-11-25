## Quick start

Information below is good reminder of commands to run.

```shell
cikit init --project=PROJECT
cd PROJECT

# Define the credentials for the matrix of droplets.
cikit matrix/define --matrix=matrix1 --domain=example.com [--ssh-key=~/.ssh/id_rsa] [--ssh-user=root] [--ssh-port=22]
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

## SSH keys protection

Always remember that you've copied SSH key-pair to the project tree! They are needed to provision a droplet, but you'll have a serious risk to loose the data on that droplet or entire virtual server, if private key become public. Share them only via private channels (private Git repositories - is ok, but better to not commit them at all).

## Documentation

- [Basic HTTP authentication](basic-http-auth) - the frontier of your server protection.
- [Jenkins](jenkins) - build project instance with incoming changes.
  - [GitHub Bot configuration](jenkins/github-bot) - pull requests manager.
  - [Reinstall Debian package](jenkins/reinstall-deb) - upgrade/downgrade Jenkins version.
  - [Parameterized builds](jenkins/builds-actions) - define your own tasks, controllable by commit messages.
- Ansible
  - [Inventory](ansible/inventory) - list of managed hosts.
- Vagrant
  - [Box](vagrant/box) - information and access details.
- Project
  - [Shippable environment configuration](project/env-config) - share environment configuration with team members.
  - [Sniffers](project/sniffers) - code quality tests.
  - [MSSQL](project/mssql) - a configuration of the MSSQL and how to use it on different PHP versions.
  - [Solr](project/solr) - all about the way it's configured.
- [Matrix](matrix) - storage and controller of virtual servers.
  - [Host](matrix/host) - prepare machine for hosting virtual machines.
  - [Domain](matrix/domain) - human-readable alias for address of your host.
  - Droplet - virtual server on the host.
    - [Ansible](matrix/droplet/ANSIBLE.md) - control droplets by Ansible from command line.
    - [GUI](matrix/droplet/UI.md) - no, thank you, I'm mouseclicker.
