#!/usr/bin/env bash

PROJECT_NAME="test_project"

cikit init --project="$PROJECT_NAME" --without-sources
cd "$PROJECT_NAME"

export ANSIBLE_HOST_KEY_CHECKING=False
export EXTRA_VARS="--web-server=nginx --php-version=7.1 --nodejs-version=6 --ruby-version=2.4.0 --solr-version=6.6.2 --mssql-install"

cikit env/start
cikit provision
