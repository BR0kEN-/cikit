#!/usr/bin/env bash
# - 1: Site URL to download from.
echo $(wget -qO- "$1/LATEST.TXT")
