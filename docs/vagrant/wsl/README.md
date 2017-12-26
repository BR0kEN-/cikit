# Installation within Windows Linux Subsystem

## Ensure OS build is ready to go

Ensure OS build number is greater than [14951](https://docs.microsoft.com/ru-ru/windows/wsl/release-notes#build-14951) (run `ver` in `cmd.exe` to check this). Refer the https://blogs.windows.com/windowsexperience/2016/10/19/announcing-windows-10-insider-preview-build-14951-for-mobile-and-pc official blog post and the https://blogs.msdn.microsoft.com/commandline/2016/10/19/interop-between-windows-and-bash explanation for more.

Make sure your are not using Enterprise version of Windows since "Fall Creators Update" cannot be installed on that one easily (valuable only if your build is lower than required). More info at https://support.microsoft.com/en-us/help/3188105/-contact-your-system-administrator-to-upgrade-windows-server-or-enterp.

Having a lower build number you won't be able to run the whole stack due to missing [WSL interoperability](https://docs.microsoft.com/en-us/windows/wsl/interop) and below operations will be redundant.

*At the moment of writing these instructions, the Windows 10 of version `1709`, having the `16299.125` build, has been used for testing*.

## Install Windows Subsystem for Linux

Remember, that **it is not recommended to use `lxrun` for installing WSL** if OS build number is `16215` or later. Please, carefully read the https://docs.microsoft.com/en-us/windows/wsl/install-win10.

Imagine we have a *good enough* build. If so, we can simplify this step by just running a PowerShell one-line command (should be in a privileged mode and will require OS restart afterward).

```powershell
Enable-WindowsOptionalFeature -Online -FeatureName Microsoft-Windows-Subsystem-Linux
```

After the system is boot again, open the Microsoft Store and use search to find `Ubuntu` or `openSUSE`. Proceed to its page and click `Get`. After distro will be downloaded, click `Launch` and do the installation.

**Not recommended, legacy installation via `lxrun`**.

![Installation via lxrun](images/16215-lxrun.png)

**Recommended installation from Microsoft Store**.

![Installation from store](images/16215-store.png)

## Install VirtualBox

This is achievable without any inconvenience and extra steps. Just download VirtualBox at https://www.virtualbox.org/wiki/Downloads and install it as a regular Windows program.

Installation of Guest Additions is not needed.

## Install PIP, Ansible and Vagrant inside of WSL

- Change the `WINDOWS_SYSTEMDRIVE` if Windows is installed not on `C:\\` drive.
- You might want to change the value of the `VAGRANT_VERSION` but it must not be lower than `1.9.5`.
- You don't need to have Vagrant as a Windows program. Do never use `vagrant.exe` in Linux in a case you already have it and don't want to remove.

Save this script to file and run it in WSL. Don't forget to restart WSL afterward.

```bash
#!/usr/bin/env bash

# Must be in lowercase.
WINDOWS_SYSDRV="c"
VAGRANT_VERSION="2.0.1"
VIRTUALBOX_EXE="/mnt/${WINDOWS_SYSDRV}/Program Files/Oracle/VirtualBox/VBoxManage.exe"
POWERSHELL_EXE="/mnt/${WINDOWS_SYSDRV}/Windows/System32/WindowsPowerShell/v1.0/powershell.exe"

################################################################################

# Can't continue without PowerShell.
if [ ! -f "${POWERSHELL_EXE}" ]; then
  echo "PowerShell cannot be found at \"${POWERSHELL_EXE}\". Are you sure Windows system drive is \"${WINDOWS_SYSDRV^^}:\\\"?"
  exit 1
elif ! command -v "powershell" > /dev/null; then
  # WSL interoperability. Vagrant will use exactly this "Linux" binary.
  sudo ln -s "${POWERSHELL_EXE}" /usr/bin/powershell
fi

powershell -Command "Get-Host"

################################################################################

# Can't continue without VirtualBox.
if [ ! -f "${VIRTUALBOX_EXE}" ]; then
  echo "VirtualBox cannot be found at \"${VIRTUALBOX_EXE}\". Is it installed?"
  exit 2
elif ! command -v "VBoxManage" > /dev/null; then
  # WSL interoperability. Vagrant will use exactly this "Linux" binary.
  sudo ln -s "${VIRTUALBOX_EXE}" /usr/bin/VBoxManage
fi

VBoxManage --version

################################################################################

LINUX_DISTRO_ID="$(python -c "import platform;print(platform.linux_distribution()[0].split(' ')[0])")"

case "${LINUX_DISTRO_ID}" in
  openSUSE|SUSE)
    if ! command -v "easy_install" > /dev/null; then
      sudo zypper addrepo --no-gpgcheck --check --refresh --name "openSUSE-42.2-OSS" http://download.opensuse.org/distribution/leap/42.2/repo/oss/ oss > /dev/null 2>&1
      sudo zypper update
      sudo zypper install --auto-agree-with-licenses --no-confirm python-setuptools
    fi

    PACKAGE_EXT="rpm"
    PACKAGE_UTIL="rpm"
    ;;

  Ubuntu)
    if ! command -v "easy_install" > /dev/null; then
      sudo apt update
      sudo apt install python-setuptools -y
    fi

    PACKAGE_EXT="deb"
    PACKAGE_UTIL="dpkg"
    ;;

  *)
    echo "The \"${LINUX_DISTRO_ID}\" Linux distribution is not supported."
    exit 3
    ;;
esac

easy_install --version

################################################################################

if ! command -v "pip" > /dev/null; then
  sudo easy_install pip
fi

pip --version

################################################################################

if ! command -v "ansible" > /dev/null; then
  sudo pip install ansible
fi

ansible --version

################################################################################

if ! command -v "vagrant" > /dev/null; then
  VAGRANT_FILENAME="vagrant_${VAGRANT_VERSION}_x86_64.${PACKAGE_EXT}"

  wget -q "https://releases.hashicorp.com/vagrant/${VAGRANT_VERSION}/${VAGRANT_FILENAME}"
  sudo ${PACKAGE_UTIL} -i "${VAGRANT_FILENAME}"
  rm "${VAGRANT_FILENAME}"
fi

vagrant --version

################################################################################

cat << 'HERE' > ~/.vagrant.profile
# Allow Vagrant to operate in WSL.
# https://www.vagrantup.com/docs/other/wsl.html#vagrant-installation
export VAGRANT_WSL_ENABLE_WINDOWS_ACCESS=1
# Without enabling this feature the ".vagrant.d" will be placed to
# the "/mnt/c/Users/$USER/.vagrant.d". This will break SSH because
# the private key will have too open permissions and you won't be
# able to apply "chmod" for the file in Windows file system. Moreover,
# we are isolating Vagrant in WSL container and don't want to expose
# boxes and other info from outside of it.
export VAGRANT_WSL_DISABLE_VAGRANT_HOME=1
HERE

if ! grep "source ~/.vagrant.profile" ~/.profile > /dev/null; then
  echo "source ~/.vagrant.profile" >> ~/.profile
fi
```

## Resolution of known problem (@todo)

Bear in mind that this step brings you an additional limitation, disallowing Vagrant to operate in multiple WSL instances (doubt someone needs this, but just FYI). The limitation is gone for sure when [the issue in Vagrant](https://github.com/hashicorp/vagrant/issues/9298) will be solved.

Run the following script if you don't have the `%LOCALAPPDATA%\lxss` directory (verify in the `cmd.exe` executing the `dir %LOCALAPPDATA%\lxss`). Check the https://github.com/berkshelf/vagrant-berkshelf/issues/323#issue-267607656 for more.

In short, it'll be missing if you install WSL from Windows Store and not by running the `lxrun /install /y` from `cmd.exe`. And it must be missing because `lxrun` - is legacy way to install WSL.

Copy and run the PowerShell script (in privileged mode).

```powershell
$WSLREGKEY="HKCU:\Software\Microsoft\Windows\CurrentVersion\Lxss"
$WSLDEFID=(Get-ItemProperty "$WSLREGKEY").DefaultDistribution
$WSLFSPATH=(Get-ItemProperty "$WSLREGKEY\$WSLDEFID").BasePath
New-Item -ItemType Junction -Path "$env:LOCALAPPDATA\lxss" -Value "$WSLFSPATH\rootfs"
```

**WARNING**: this step - is a workaround for the issue and has been added for process simplification. If you think you have enough experience to patch the Vagrant with the https://github.com/hashicorp/vagrant/pull/9300 - do it and skip that PowerShell crutch.

## All ready

- **Do never place files, you're gonna edit, within WSL**. Locate them on `/mnt/` only. Modifying data in Linux subsystem by Windows tools will lead to **their corruption and loss**. The https://github.com/Microsoft/WSL/issues/1283#issuecomment-352183860 issue has some clarification on that.
- Install CIKit as usual, create a project and provision VM.

## Limitations

- You have to manage hostnames of your projects manually by editing the `%SYSTEMROOT%\system32\drivers\etc\hosts`. Windows system files are not modifiable from WSL even if it's running in privileged mode. Moreover, do not run WSL with administrative privileges because VirtualBox won't operate properly.
- You are not able to use NFS shares and forced to go with VBoxSF.
- Microsoft Edge ignores the modifications of `hosts` file and doesn't open websites (temporary, investigation on this is going forward).

## Result

As a proof, you may take a look at the screenshot which shows that single Windows instance might have many WSL containers running with the CIKit.

![CIKit VM on openSUSE and Ubuntu](images/wsl-cikit-opensuse-and-ubuntu.png)

*For now it's possible only with the https://github.com/hashicorp/vagrant/pull/9300 patch applied. (@todo)*
