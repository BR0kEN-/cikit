#!/usr/bin/env bash

CIKIT_PHP_VERSION=$1
CIKIT_NODEJS_VERSION=$2
SETUP_SOLR=$3

: ${CIKIT_PHP_VERSION:="7.0"}
: ${CIKIT_NODEJS_VERSION:="6"}
: ${SETUP_SOLR:="false"}

ANSIBLE_ARGS="-vvvv --cikit-php-version=${CIKIT_PHP_VERSION} --cikit-nodejs-version=${CIKIT_NODEJS_VERSION} --setup-solr=${SETUP_SOLR}"

./cikit repository --project=test
\cd test
\vagrant up
