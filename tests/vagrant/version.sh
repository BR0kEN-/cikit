#!/usr/bin/env bash
# - 1: Name of package to download.
awk -F '_' '{print $2}' <<< "$1"
