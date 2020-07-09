#!/usr/bin/env bash

# This script will test postgrey
# It is used for s6-notifyoncheck in service start scripts to bring things up in order

netstat -an | grep 10023 > /dev/null 2>&1
exit $?
