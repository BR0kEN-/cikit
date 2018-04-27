#!/usr/bin/env bash

set -e

VAGRANT_VERSION="$2"
: "${VAGRANT_VERSION:="2.0.3"}"

# ==============================================================================
# Utilities.

has() {
  command -v "$1" > /dev/null && return 0 || return 1
}

symlink() {
  if [ ! -f "$2" ]; then
    echo "The \"$1\" cannot be found at \"$2\". $3"
    exit 1
  elif ! has "$1"; then
    # WSL interoperability. Vagrant will use exactly this "Linux" binary.
    sudo ln -s "$2" "/usr/bin/$1"
  fi
}

# ==============================================================================
# Set up the runtime variables.

# Drive letter must be in lowercase.
WINDOWS_SYSDRV="$(powershell.exe -Command '$env:SYSTEMDRIVE.replace(":", "").ToLower()')"
# Trim trailing whitespaces.
WINDOWS_SYSDRV="${WINDOWS_SYSDRV%"${WINDOWS_SYSDRV##*[![:space:]]}"}"
VBOXMANAGE_EXE="/mnt/$WINDOWS_SYSDRV/Program Files/Oracle/VirtualBox/VBoxManage.exe"
POWERSHELL_EXE="/mnt/$WINDOWS_SYSDRV/Windows/System32/WindowsPowerShell/v1.0/powershell.exe"

# ==============================================================================
# Create symlinks for VBoxManage and PowerShell.

symlink powershell "$POWERSHELL_EXE" "Are you sure Windows system drive is \"${WINDOWS_SYSDRV^^}:\\\"?"
powershell -Command "Get-Host"

symlink VBoxManage "$VBOXMANAGE_EXE" "Is it installed?"
VBoxManage --version

# ==============================================================================
# Install the "python-setuptools" and check whether Linux distro is supported.

LINUX_DISTRO_ID=""

for PYTHON_COMMAND in "python" "python2" "python3"; do
  if has "$PYTHON_COMMAND"; then
    LINUX_DISTRO_ID="$(${PYTHON_COMMAND} -c "import platform;print(platform.linux_distribution()[0].split(' ')[0])")"
    break
  fi
done

case "$LINUX_DISTRO_ID" in
  openSUSE|SUSE)
    if ! has easy_install; then
      sudo zypper addrepo --no-gpgcheck --check --refresh --name "openSUSE-42.2-OSS" http://download.opensuse.org/distribution/leap/42.2/repo/oss/ oss > /dev/null 2>&1
      sudo zypper update
      sudo zypper install --auto-agree-with-licenses --no-confirm python-setuptools
    fi

    PACKAGE_EXT="rpm"
    PACKAGE_UTIL="rpm"
    ;;

  Ubuntu)
    if ! has easy_install; then
      sudo apt update
      sudo apt install python-setuptools -y
    fi

    PACKAGE_EXT="deb"
    PACKAGE_UTIL="dpkg"
    ;;

  '')
    echo "Cannot compute a name of Linux distribution."
    exit 3
    ;;

  *)
    echo "The \"$LINUX_DISTRO_ID\" Linux distribution is not supported."
    exit 4
    ;;
esac

easy_install --version

# ==============================================================================
# Install PIP.

has pip || sudo easy_install pip
pip --version

# ==============================================================================
# Install Ansible.

has ansible || sudo pip install ansible
ansible --version

# ==============================================================================
# Install Vagrant.

if ! has vagrant; then
  VAGRANT_FILENAME="vagrant_${VAGRANT_VERSION}_x86_64.$PACKAGE_EXT"

  wget -q "https://releases.hashicorp.com/vagrant/$VAGRANT_VERSION/$VAGRANT_FILENAME"
  sudo ${PACKAGE_UTIL} -i "$VAGRANT_FILENAME"
  rm "$VAGRANT_FILENAME"
fi

vagrant --version

# ==============================================================================
# Configure environment for Vagrant operation.

cat << 'EOF' > ~/.vagrant.profile
# Allow Vagrant to operate in WSL.
# https://www.vagrantup.com/docs/other/wsl.html#vagrant-installation
export VAGRANT_WSL_ENABLE_WINDOWS_ACCESS=1
EOF

if ! grep "source ~/.vagrant.profile" ~/.profile > /dev/null; then
  echo "source ~/.vagrant.profile" >> ~/.profile
fi
