#!/usr/bin/env bash
# - 1: Site URL to download from.
wget -qO- "$1" | grep -o '>vagrant_.*<' | head -n1 | tr -d '><'
