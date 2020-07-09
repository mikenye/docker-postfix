#!/usr/bin/env bash

# This script will test postfix
# It is used for s6-notifyoncheck in service start scripts to bring things up in order

postfix status > /dev/null 2>&1
exit $?
