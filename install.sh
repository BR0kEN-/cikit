#!/usr/bin/env bash

INSTALL_PATH="/usr/local/share/cikit"

if ! \command -v "sudo" >/dev/null && \command -v "cygstart" >/dev/null; then
  sudo()
  {
    cygstart --action=runas "$@"
  }
fi

if [ "--no-requirements-check" != "${1}" ]; then
  MISSING=""

  for COMMAND in vagrant VBoxManage ansible-playbook; do
    if ! \command -v "${COMMAND}" >/dev/null; then
      MISSING+="\n- ${COMMAND}"
    fi
  done

  if [ -n "${MISSING}" ]; then
    \echo -e "The following software were not found on your machine, so continuation is not possible:${MISSING}"
    \exit 1
  fi
fi

if [ ! -d "${INSTALL_PATH}" ]; then
  sudo \mkdir -p "${INSTALL_PATH}"
fi

if sudo \git clone https://github.com/BR0kEN-/cikit.git --recursive "${INSTALL_PATH}"; then
  sudo \ln -s "${INSTALL_PATH}/bash/cikit" /usr/local/bin/cikit
  sudo \chown -R "$(\whoami)" "${INSTALL_PATH}"
fi
