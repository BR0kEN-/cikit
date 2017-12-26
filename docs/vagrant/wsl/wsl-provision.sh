#!/usr/bin/env bash

# Drive letter must be in lowercase.
WINDOWS_SYSDRV="$1"
VAGRANT_VERSION="$2"

: "${WINDOWS_SYSDRV:="c"}"
: "${VAGRANT_VERSION:="2.0.1"}"

# ==============================================================================
# Set up the runtime variables.

VIRTUALBOX_EXE="/mnt/${WINDOWS_SYSDRV}/Program Files/Oracle/VirtualBox/VBoxManage.exe"
POWERSHELL_EXE="/mnt/${WINDOWS_SYSDRV}/Windows/System32/WindowsPowerShell/v1.0/powershell.exe"

# ==============================================================================
# Check whether PowerShell is available and symlink it to the WSL.

if [ ! -f "${POWERSHELL_EXE}" ]; then
  echo "PowerShell cannot be found at \"${POWERSHELL_EXE}\". Are you sure Windows system drive is \"${WINDOWS_SYSDRV^^}:\\\"?"
  exit 1
elif ! command -v "powershell" > /dev/null; then
  # WSL interoperability. Vagrant will use exactly this "Linux" binary.
  sudo ln -s "${POWERSHELL_EXE}" /usr/bin/powershell
fi

powershell -Command "Get-Host"

# ==============================================================================
# Check whether VBoxManage is available and symlink it to the WSL.

if [ ! -f "${VIRTUALBOX_EXE}" ]; then
  echo "VirtualBox cannot be found at \"${VIRTUALBOX_EXE}\". Is it installed?"
  exit 2
elif ! command -v "VBoxManage" > /dev/null; then
  # WSL interoperability. Vagrant will use exactly this "Linux" binary.
  sudo ln -s "${VIRTUALBOX_EXE}" /usr/bin/VBoxManage
fi

VBoxManage --version

# ==============================================================================
# Install the "python-setuptools" and check whether Linux distro is supported.

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

# ==============================================================================
# Install PIP.

if ! command -v "pip" > /dev/null; then
  sudo easy_install pip
fi

pip --version

# ==============================================================================
# Install Ansible.

if ! command -v "ansible" > /dev/null; then
  sudo pip install ansible
fi

ansible --version

# ==============================================================================
# Install Vagrant.

if ! command -v "vagrant" > /dev/null; then
  VAGRANT_FILENAME="vagrant_${VAGRANT_VERSION}_x86_64.${PACKAGE_EXT}"

  wget -q "https://releases.hashicorp.com/vagrant/${VAGRANT_VERSION}/${VAGRANT_FILENAME}"
  sudo ${PACKAGE_UTIL} -i "${VAGRANT_FILENAME}"
  rm "${VAGRANT_FILENAME}"
fi

vagrant --version

# ==============================================================================
# Configure environment for Vagrant operation.

cat << 'EOF' > ~/.vagrant.profile
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
EOF

if ! grep "source ~/.vagrant.profile" ~/.profile > /dev/null; then
  echo "source ~/.vagrant.profile" >> ~/.profile
fi
