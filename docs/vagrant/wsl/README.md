# Installation within Windows Linux Subsystem

- Ensure OS build number is greater than [14951](https://docs.microsoft.com/ru-ru/windows/wsl/release-notes#build-14951) (run `ver` in `cmd.exe` to check this). Refer the https://blogs.windows.com/windowsexperience/2016/10/19/announcing-windows-10-insider-preview-build-14951-for-mobile-and-pc official blog post and the https://blogs.msdn.microsoft.com/commandline/2016/10/19/interop-between-windows-and-bash explanation for more.

  Make sure your are not using Enterprise version of Windows since "Fall Creators Update" cannot be installed on that one easily. More info at https://support.microsoft.com/en-us/help/3188105/-contact-your-system-administrator-to-upgrade-windows-server-or-enterp.

  Having a lower build number you won't be able to run the whole stack and below operations will be redundant.

- Enable developer mode and [install Ubuntu as Windows Subsytem for Linux (WSL)](https://docs.microsoft.com/en-us/windows/wsl/install-win10).

- Install [VirtualBox](https://www.virtualbox.org/wiki/Downloads) as a regular Windows program. Installation of Guest Additions isn't needed.

- Install Pip and Ansible inside of a WSL.

  ```bash
  sudo apt update
  sudo apt install python-setuptools -y
  sudo easy_install pip
  sudo pip install ansible
  ```

- Install Vagrant inside of a WSL (https://www.vagrantup.com/docs/other/wsl.html#vagrant-installation, https://github.com/Microsoft/WSL/issues/733#issuecomment-266175270). You might change the value of the `VAGRANT_VERSION` but it must not be lower than `1.9.5`.

  You don't need to have Vagrant as a Windows program. Do never use `vagrant.exe` in a case you already have it and don't want to remove.

  ```bash
  VAGRANT_VERSION="2.0.1"
  VAGRANT_FILENAME="vagrant_${VAGRANT_VERSION}_x86_64.deb"

  wget -q "https://releases.hashicorp.com/vagrant/${VAGRANT_VERSION}/${VAGRANT_FILENAME}"
  sudo dpkg -i "${VAGRANT_FILENAME}"
  rm "${VAGRANT_FILENAME}"
  ```

- Relying on Windows / WSL interoperability, cheat a WSL that `VBoxManage` is a Linux binary. This needed because Vagrant uses exactly that executable.

  ```bash
  sudo ln -s "/mnt/c/Program Files/Oracle/VirtualBox/VBoxManage.exe" /usr/bin/VBoxManage
  ```

- Run the following script if you don't have the `%LOCALAPPDATA%\lxss` directory (verify in the `cmd.exe` executing the `dir %LOCALAPPDATA%\lxss`). Check the https://github.com/berkshelf/vagrant-berkshelf/issues/323#issue-267607656 for more.

  In short, it'll be missing if you install Ubuntu from Windows Store and not by running the `lxrun /install /y` from `cmd.exe`.

  Start PowerShell with administrative privileges executing this by pasting into the search bar.

  ```
  cmd /c powershell "Start-Process powershell -Verb runAs"
  ```

  Copy and run the PowerShell script.

  ```powershell
  $WSLREGKEY="HKCU:\Software\Microsoft\Windows\CurrentVersion\Lxss"
  $WSLDEFID=(Get-ItemProperty "$WSLREGKEY").DefaultDistribution
  $WSLFSPATH=(Get-ItemProperty "$WSLREGKEY\$WSLDEFID").BasePath
  New-Item -ItemType Junction -Path "$env:LOCALAPPDATA\lxss" -Value "$WSLFSPATH\rootfs"
  ```

- Allow Vagrant to use VirtualBox within WSL. It'll be easier for you to preserve this variable in `~/.profile`, for instance.

  ```bash
  # Without enabling this feature the ".vagrant.d" will be placed to
  # the "/mnt/c/Users/$USER/.vagrant.d". This will break SSH because
  # the private key will have too open permissions and you won't be
  # able to apply "chmod" for the file in Windows file system.
  export VAGRANT_WSL_DISABLE_VAGRANT_HOME=1
  export VAGRANT_WSL_ENABLE_WINDOWS_ACCESS=1
  ```

- Do never place files, you're gonna edit, within WSL. Locate them on `/mnt/` only. Modifying data in Linux subsystem by Windows tools will lead to **their corruption and loss**. The https://github.com/Microsoft/WSL/issues/1283#issuecomment-352183860 issue has some clarification on that.

- Install CIKit as usual, create a project and provision a VM. Remember that you'll be required to add hostnames of your projects manually to the `%SYSTEMROOT%\system32\drivers\etc\hosts`. Use `127.0.0.1` and not the actual IP of VM. Read the https://github.com/Microsoft/WSL/issues/1032#issuecomment-244160207 to know why.
