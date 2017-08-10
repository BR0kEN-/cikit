#!/usr/bin/env bash

INSTALL_PATH="/var/lib/cikit"
INSTALL_DIR=$(\dirname "${INSTALL_PATH}")

if [ -d "${INSTALL_DIR}" ]; then
  \mkdir -p "${INSTALL_DIR}"
fi

\git clone https://github.com/BR0kEN-/cikit.git --branch=master "${INSTALL_PATH}"
\ln -s "${INSTALL_PATH}/bash/cikit" /usr/local/bin/cikit
