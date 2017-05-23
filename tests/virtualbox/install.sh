#!/usr/bin/env bash

# @todo Adapt this script for multi OS operability.

ARCH="$1"
DEST="$2"
SITE="http://download.virtualbox.org/virtualbox"

# Example: "5.1.22".
VERSION=$(wget -qO- "${SITE}/LATEST.TXT")
# Example: "VirtualBox-5.1.22-115126-Win.exe".
FILENAME=$(wget -qO- "${SITE}/${VERSION}/MD5SUMS" | awk -F '*' '/.exe/ {print $2}')
# Example: "115126".
BUILD_ID=$(awk -F '-' '{print $3}' <<< "${FILENAME}")
INSTALL="VirtualBox-${VERSION}-r${BUILD_ID}-MultiArch_"

if [ "64" -eq "${ARCH}" ]; then
  INSTALL+="amd64"
else
  INSTALL+="x86"
fi

INSTALL+=".msi"

wget -nc -O "${DEST}/${FILENAME}" "${SITE}/${VERSION}/${FILENAME}"
echo "${FILENAME}|${INSTALL}"
