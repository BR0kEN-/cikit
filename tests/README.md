# CIKit Tests

## Cygwin

Script for automate Cygwin installation and configuration for Windows 7, 8 and 10.

```shell
# "test-vm"     - to create CIKit project.
# "7.0"         - PHP version ("7.0" by default).
# "6"           - NodeJS version ("6" by default).
# "6.5.1"       - Solr version ("6.5.1" by default).
# "2.4.0"       - Ruby version ("2.4.0" by default).
install.bat [test-vm] [7.0] [6] [6.5.1] [2.4.0]
```

**Important**: ensure that script will be executed with administrative privileges in case of passing `test-vm` as an argument!

# Todo

- [x] Add script to automate installation of Cygwin on Windows
- [ ] Add script to automate installation of VirtualBox
- [ ] Add script to automate installation of Vagrant
