#!/usr/bin/env bash

cikit init --project=test_project --without-sources
cd test_project
cikit env/start
cikit ssh env
cd ../
