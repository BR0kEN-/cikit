# Reinstall Debian package

May happen that you will need to reinstall, downgrade or upgrade version of Jenkins and **CIKit** provides such possibility. By default we supply the package with [predefined value](../../../scripts/roles/cikit-jenkins/vars/main.yml#L5). Before updating it there we are checking operability and compatibility with plugins, so you can rely on it.

If you have accidentally broke the service, removed the package or some dependency (*not configuration*) then just reinstall the package executing the next command on your local machine:

```shell
./cikit provision --limit=<SERVER_NAME_FROM_INVENTORY> --tags="jenkins" --jenkins-reinstall-deb
```

- What is [SERVER_NAME_FROM_INVENTORY](../../ansible/inventory)?

## Changing version

If you need to have concrete version then [update it manually](../../../scripts/roles/cikit-jenkins/vars/main.yml#L5) and execute above command.
