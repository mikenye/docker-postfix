#!/usr/bin/env bash

# This script will test clamd
# It is used for s6-notifyoncheck in service start scripts to bring things up in order

clamdscan /VERSIONS > /dev/null 2>&1
exit $?
