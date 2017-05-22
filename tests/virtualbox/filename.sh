#!/usr/bin/env bash
# - 1: Site URL to download from.
# - 2: Version of VirtualBox to download.
wget -qO- "$1/$2/MD5SUMS" | awk -F '*' '/.exe/ {print $2}'
