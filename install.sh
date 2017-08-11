#!/usr/bin/env bash

INSTALL_PATH="/usr/local/share/cikit"
INSTALL_DIR=$(\dirname "${INSTALL_PATH}")

if [ -d "${INSTALL_DIR}" ]; then
  \sudo \mkdir -p "${INSTALL_DIR}"
fi

# @todo Replace "issues/45" by "master".
\sudo \git clone https://github.com/BR0kEN-/cikit.git --branch=issues/45 "${INSTALL_PATH}"
\sudo \ln -s "${INSTALL_PATH}/bash/cikit" /usr/local/bin/cikit
