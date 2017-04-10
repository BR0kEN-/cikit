#!/usr/bin/env bash

export ANSIBLE_ARGS="-vvvv"

CIKIT_PHP_VERSION=$1
CIKIT_NODEJS_VERSION=$2
SETUP_SOLR=$3

: ${CIKIT_PHP_VERSION:="7.0"}
: ${CIKIT_NODEJS_VERSION:="6"}
: ${SETUP_SOLR:="false"}

# Change directory to "tests".
\cd -P -- $(dirname -- $0)
# Go to root directory of CIKit.
\cd ..

./cikit repository \
  --project=cikit-test-project \
  --cikit-php-version=${CIKIT_PHP_VERSION} \
  --cikit-nodejs-version=${CIKIT_NODEJS_VERSION} \
  --setup-solr=${SETUP_SOLR}

\cd cikit-test-project/
\vagrant up
