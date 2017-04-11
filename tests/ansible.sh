#!/usr/bin/env bash

\pip --version

if [ $? -gt 0 ]; then
  \easy_install-2.7 pip
fi

\ansible --version

if [ $? -gt 0 ]; then
  \pip install ansible
fi
