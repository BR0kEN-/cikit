#!/usr/bin/env bash

# @todo Adapt this script for multi OS operability.

ARCH="$1"
DEST="$2"
SITE="http://download.virtualbox.org/virtualbox"

# Example: "5.1.22".
VERSION=$(wget -qO- "${SITE}/LATEST.TXT")
# Example: "VirtualBox-5.1.22-115126-Win.exe".
SETUP_EXE=$(wget -qO- "${SITE}/${VERSION}/MD5SUMS" | awk -F '*' '/.exe/ {print $2}')
# Example: "115126".
BUILD_ID=$(awk -F '-' '{print $3}' <<< "${SETUP_EXE}")
SETUP_MSI="VirtualBox-${VERSION}-r${BUILD_ID}-MultiArch_"

if [ "64" -eq "${ARCH}" ]; then
  SETUP_MSI+="amd64"
else
  SETUP_MSI+="x86"
fi

SETUP_MSI+=".msi"

wget -nc -O "${DEST}/${SETUP_EXE}" "${SITE}/${VERSION}/${SETUP_EXE}"
echo "${SETUP_EXE}|${SETUP_MSI}|${VERSION}"
