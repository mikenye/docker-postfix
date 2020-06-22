#!/usr/bin/with-contenv bash
# shellcheck shell=bash

# Check to make sure the correct command line arguments have been set
EXITCODE=0
if [ -z "${POSTMASTER_EMAIL}" ]; then
  echo "ERROR: POSTMASTER_EMAIL environment variable not set"
  EXITCODE=1
fi
if [ $EXITCODE -ne 0 ]; then
  exit 1
fi

# Exit on failure
set -e

# Write /etc/aliases
echo "postmaster: ${POSTMASTER_EMAIL}" > /etc/aliases
echo "root:       ${POSTMASTER_EMAIL}" >> /etc/aliases

# Run newaliases
newaliases
