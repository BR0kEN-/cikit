## Quick start

Information below is good reminder of commands to run.

```shell
git clone --recursive https://github.com/BR0kEN-/cikit.git
cd cikit

echo "matrix1 ansible_host=example.com ansible_user=root ansible_ssh_private_key_file=~/.ssh/id_rsa" >> inventory
./cikit matrix/matrix --limit=matrix1
# Create first droplet - "cikit01".
./cikit matrix/matrix --limit=matrix1 --tags=vm --droplet-add
# Note that "ansible_ssh_private_key_file" will be generated and used automatically, so no need to specify it here.
echo "cikit01 ansible_host=example.com ansible_user=root" >> inventory

./cikit repository --project=PROJECT --cmf=drupal --version=7.54
cd PROJECT

# Provision remote CI server.
#./cikit .cikit/provision --limit=cikit01
# Add project to existing, already provisioned, server.
#./cikit .cikit/jenkins-job --limit=cikit01

# Provision local virtual machine.
vagrant up --provision
```

## SSH keys protection

In case of provisioning remote server, SSH key-pair will be generated in `PROJECT/scripts/files/ssh-keys/`! You have serious risk to loose data on droplet or entire virtual server if private key become public. Share them only via private channels.

## Documentation

- [Basic HTTP authentication](basic-http-auth) - the frontier of your server protection.
- [Jenkins](jenkins) - build project instance with incoming changes.
  - [GitHub Bot configuration](jenkins/github-bot) - pull requests manager.
  - [Reinstall Debian package](jenkins/reinstall-deb) - upgrade/downgrade Jenkins version.
- Ansible
  - [Inventory](ansible/inventory) - list of managed hosts.
- Vagrant
  - [Box](vagrant/box) - information and access details.
- Project
  - [Sniffers](project/sniffers) - code quality tests.
  - [Solr](project/solr) - all about the way it's configured.
- [Matrix](matrix) - storage and controller of virtual servers.
  - [Host](matrix/host) - prepare machine for hosting virtual machines.
  - [Domain](matrix/domain) - human-readable alias for address of your host.
  - Droplet - virtual server on the host.
    - [Ansible](matrix/droplet/ANSIBLE.md) - control droplets by Ansible from command line.
    - [GUI](matrix/droplet/UI.md) - no, thank you, I'm mouseclicker.
