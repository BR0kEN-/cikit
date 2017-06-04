#!/usr/bin/env bash

# @todo Adapt this script for multi OS operability.

OS="$1"
ARCH="$2"
DEST="$3"
SITE="https://releases.hashicorp.com/vagrant"

SETUP_EXE=$(wget -qO- "${SITE}" | grep -o '>vagrant_.*<' | head -n1 | tr -d '><')
VERSION=$(awk -F '_' '{print $2}' <<< "${SETUP_EXE}")
DOWNLOAD_SECTION="${SITE}/${VERSION}"
SETUP_MSI="${SETUP_EXE}.msi"

wget -nc -O "${DEST}/${SETUP_MSI}" "${DOWNLOAD_SECTION}/${SETUP_MSI}"
echo "${SETUP_EXE}|${SETUP_MSI}|${VERSION}|${DOWNLOAD_SECTION}"
