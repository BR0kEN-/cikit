# Installation within Windows Linux Subsystem

- Install VirtualBox as a Windows program.

- Enable developer mode and [install Ubuntu as Windows Subsytem for Linux (WSL)](https://docs.microsoft.com/en-us/windows/wsl/install-win10).

- Install Vagrant inside of a WSL (https://www.vagrantup.com/docs/other/wsl.html#vagrant-installation, https://github.com/Microsoft/WSL/issues/733#issuecomment-266175270).

  ```bash
  VAGRANT_VERSION="2.0.1"
  VAGRANT_FILENAME="vagrant_${VAGRANT_VERSION}_x86_64.deb"

  wget -s "https://releases.hashicorp.com/vagrant/${VAGRANT_VERSION}/${VAGRANT_FILENAME}"
  sudo dpkg -i "${VAGRANT_FILENAME}"
  rm "${VAGRANT_FILENAME}"
  sudo ln -s "/mnt/c/Program Files/Oracle/VirtualBox/VBoxManage.exe" /usr/bin/VBoxManage
  ```

- Run the following script if you don't have the `dir %LOCALAPPDATA%\lxss` directory (https://github.com/berkshelf/vagrant-berkshelf/issues/323#issue-267607656).

  Start PowerShell with administrative privileges.
  
  ```
  cmd /c powershell "start-process powershell -verb runas"
  ```

  Run PowerShell script.

  ```powershell
  $WSLREG="HKCU:\Software\Microsoft\Windows\CurrentVersion\Lxss"
  $WSLID=(Get-ItemProperty "$WSLREG").DefaultDistribution
  $WSLFS=(Get-ItemProperty "$WSLREG\$WSLID").BasePath
  New-Item -ItemType Junction -Path "$env:LOCALAPPDATA\lxss" -Value "$WSLFS\rootfs"
  ```

- In `%SYSTEMROOT%\system32\drivers\etc\hosts` you will be required to add hostnames manually for the `127.0.0.1` IP (https://github.com/Microsoft/WSL/issues/1032#issuecomment-244160207).

- Run `bash` and do `export VAGRANT_WSL_ENABLE_WINDOWS_ACCESS=1`. Better add it permanently to the `~/.profile` to preserve a state.
