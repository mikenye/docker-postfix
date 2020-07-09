#!/usr/bin/with-contenv bash
# shellcheck shell=bash

set -x

if [ "${ENABLE_POSTGREY}" = "true" ]; then
  /usr/local/bin/update_postgrey_whitelist
fi
