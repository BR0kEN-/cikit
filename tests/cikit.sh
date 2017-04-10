#!/usr/bin/env bash

CIKIT_PHP_VERSION=$1
CIKIT_NODEJS_VERSION=$2
SETUP_SOLR=$3

: ${CIKIT_PHP_VERSION:="7.0"}
: ${CIKIT_NODEJS_VERSION:="6"}
: ${SETUP_SOLR:="false"}

export ANSIBLE_ARGS="-vvvv"
# Answer on the questions appearing during Vagrant provisioning.
export EXTRA_VARS="--cikit-php-version=${CIKIT_PHP_VERSION} --cikit-nodejs-version=${CIKIT_NODEJS_VERSION} --setup-solr=${SETUP_SOLR}"

# Change directory to "tests".
\cd -P -- $(dirname -- $0)
# Go to root directory of CIKit.
\cd ../

./cikit repository --project=cikit-test-project

\cd cikit-test-project/
\vagrant up
