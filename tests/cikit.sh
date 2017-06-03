#!/usr/bin/env bash

PROJECT="cikit-test"
ANSIBLE_ARGS="-vv"

VERSION_PHP="$1"
VERSION_NODEJS="$2"
VERSION_SOLR="$3"
VERSION_RUBY="$4"

: ${VERSION_PHP:="7.0"}
: ${VERSION_NODEJS:="6"}
: ${VERSION_SOLR:="6.5.1"}
: ${VERSION_RUBY:="2.4.0"}

# Change directory to "tests".
cd -P -- "$(dirname -- "$0")"
# Go to root directory of CIKit.
cd ../

if [ -d "${PROJECT}" ]; then
  echo "[INFO] Existing project found. Checking for existing VM..."
  VM_ID="$(vagrant global-status | awk -v pattern="${PROJECT}" '$0~pattern {print $1}')"

  if [ "" != "${VM_ID}" ]; then
    echo "[INFO] Existing VM found. Destroying..."
    cd "${PROJECT}"
    vagrant destroy -f
    cd ../
  fi

  echo "[INFO] Removing existing project..."
  rm -rf "${PROJECT}"
fi

./cikit repository --project="${PROJECT}" --without-sources

cd "${PROJECT}"

EXTRA_VARS="--php-version=${VERSION_PHP} --nodejs-version=${VERSION_NODEJS} --solr-version=${VERSION_SOLR} --ruby-version${VERSION_RUBY}" vagrant up
