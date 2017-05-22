#!/usr/bin/env bash
# - 1: Name of file to download, like "VirtualBox-5.1.22-115126-Win.exe".
awk -F '-' '{print $3}' <<< "$1"
