#!/usr/bin/env bash

# Download and (re)start:
# ./selenium.sh http://example.com/selenium/2.46.jar
# Re-download and (re)start:
# ./selenium.sh http://example.com/selenium/2.53.jar --force
# Restart:
# ./selenium.sh

DOWNLOAD_URL="$1"
FILENAME="selenium.jar"
ROOT=".vagrant"

DESTINATION="${ROOT}/${FILENAME}"
LOGFILE="${ROOT}/${FILENAME%%.*}"
PIDFILE="${LOGFILE}.pid"

if [[ ! -f ${DESTINATION} || "$2" == "--force" ]]; then
  if [ -z ${DOWNLOAD_URL} ]; then
    echo "You have not specified an URL for downloading."
    exit 1
  fi

  if [ ! -d ${ROOT} ]; then
    echo "Virtual machine is not running. Try \"vagrant up\" to fix this."
    exit 2
  fi

  curl -O ${DOWNLOAD_URL}

  if [ $? -gt 0 ]; then
    echo "Cannot download file: ${DOWNLOAD_URL}"
    exit 3
  fi

  mv ${DOWNLOAD_URL##*/} ${DESTINATION}
fi

if [ -f ${PIDFILE} ]; then
  PID=$(cat ${PIDFILE})

  if [ -n ${PID} ]; then
    kill ${PID} > /dev/null 2>&1
  fi
fi

nohup java -jar ${DESTINATION} -role node > ${LOGFILE}.out.log 2> ${LOGFILE}.error.log < /dev/null &
echo $! > ${PIDFILE}
