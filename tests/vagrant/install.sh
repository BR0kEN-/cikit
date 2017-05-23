#!/usr/bin/env bash

# @todo Adapt this script for multi OS operability.

ARCH="$1"
DEST="$2"
SITE="https://releases.hashicorp.com/vagrant"

FILENAME=$(wget -qO- "${SITE}" | grep -o '>vagrant_.*<' | head -n1 | tr -d '><')
VERSION=$(awk -F '_' '{print $2}' <<< "${FILENAME}")
INSTALL="${FILENAME}.msi"

wget -nc -O "${DEST}/${INSTALL}" "${SITE}/${VERSION}/${INSTALL}"
echo "${FILENAME}|${INSTALL}"
