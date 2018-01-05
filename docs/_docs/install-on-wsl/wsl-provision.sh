#!/usr/bin/env bash

VAGRANT_VERSION="$2"
: "${VAGRANT_VERSION:="2.0.1"}"

# ==============================================================================
# Set up the runtime variables.

# Drive letter must be in lowercase.
WINDOWS_SYSDRV="$(powershell.exe -Command '$env:SYSTEMDRIVE.replace(":", "").ToLower()')"
# Trim trailing whitespaces.
WINDOWS_SYSDRV="${WINDOWS_SYSDRV%"${WINDOWS_SYSDRV##*[![:space:]]}"}"
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

LINUX_DISTRO_ID=""

for PYTHON_COMMAND in "python" "python2" "python3"; do
  if command -v "${PYTHON_COMMAND}" > /dev/null; then
    LINUX_DISTRO_ID="$(${PYTHON_COMMAND} -c "import platform;print(platform.linux_distribution()[0].split(' ')[0])")"
    break
  fi
done

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

  '')
    echo "Cannot compute a name of Linux distribution."
    exit 3
    ;;

  *)
    echo "The \"${LINUX_DISTRO_ID}\" Linux distribution is not supported."
    exit 4
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
EOF

if ! grep "source ~/.vagrant.profile" ~/.profile > /dev/null; then
  echo "source ~/.vagrant.profile" >> ~/.profile
fi

# ==============================================================================
# Patch Vagrant.
# @todo Remove patching section when the https://github.com/hashicorp/vagrant/issues/9298 issue will be resolved.

VAGRANT_PATCH_NAME="vagrant-${VAGRANT_VERSION}-issue-9298.patch"
VAGRANT_INSTALL_DIR="/opt/vagrant/embedded/gems/gems/vagrant-${VAGRANT_VERSION}"

cd "${VAGRANT_INSTALL_DIR}"

# Proceed only if we don't have the patch.
if [ ! -f "${VAGRANT_PATCH_NAME}" ]; then
  VAGRANT_PATCH_URL="https://raw.githubusercontent.com/BR0kEN-/cikit/master/docs/vagrant/wsl/patches/${VAGRANT_PATCH_NAME}"

  # Check whether the patch can be downloaded.
  if wget -q --spider "${VAGRANT_PATCH_URL}"; then
    sudo wget -q "${VAGRANT_PATCH_URL}"

    # Apply the patch only if it wasn't applied previously.
    if sudo patch -p1 -N --dry-run < ${VAGRANT_PATCH_NAME} > /dev/null; then
      sudo patch -p1 < ${VAGRANT_PATCH_NAME}
    fi
  else
    cat << HERE
$(tput setaf 3)[WARNING] Patch for the Vagrant ${VAGRANT_VERSION} is missing and you have to create and apply it by yourself.

Use the codebase from https://github.com/hashicorp/vagrant/pull/9300 PR.
HERE
  fi
fi
