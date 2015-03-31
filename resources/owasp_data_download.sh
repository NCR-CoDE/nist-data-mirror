#!/bin/bash

set -e

LOCKFILE="running.lock"

if [[ -f $LOCKFILE ]]; then
  LOCK_PID=$(cat $LOCKFILE)
  ps -fp $LOCK_PID
  if [[ $? -eq 1 ]]; then
    echo "No process found with pid $LOCK_PID so deleting $LOCKFILE"
    rm $LOCKFILE
  else
    echo "A process is already running so killing it : $LOCK_PID"
    kill $LOCK_PID
    rm $LOCKFILE
  fi
fi

echo $$ > $LOCKFILE

NEXUS_SERVER="https://nexus.ncrcoe.com/nexus"
DOWNLOAD_JAR_FILE="nist-data-mirror.jar"
DOWNLOAD_JAR_FILE_VERSION="1.0.1"
TEMP_DIR="temp_download_dir"

rm -rf $TEMP_DIR

rm -f $DOWNLOAD_JAR_FILE
wget "${NEXUS_SERVER}/service/local/artifact/maven/redirect?r=thirdparty&g=com.ncr.mobile.util&a=nist-data-mirror&v=${DOWNLOAD_JAR_FILE_VERSION}&e=jar" -O $DOWNLOAD_JAR_FILE

java -jar $DOWNLOAD_JAR_FILE $TEMP_DIR
mv $TEMP_DIR/* /var/www/owasp
echo "The files have been moved into place."
rm -f $LOCKFILE
exit 0

