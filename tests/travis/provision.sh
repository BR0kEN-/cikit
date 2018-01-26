#!/usr/bin/env bash

PROJECT_NAME="test_project"

cikit init --project="$PROJECT_NAME"
cd "$PROJECT_NAME"

ANSIBLE_INVENTORY="localhost," EXTRA_ARGS="--web-server=nginx --php-version=7.1 --nodejs-version=6 --ruby-version=2.4.0 --solr-version=6.6.2 --mssql-install" cikit provision --limit=localhost
