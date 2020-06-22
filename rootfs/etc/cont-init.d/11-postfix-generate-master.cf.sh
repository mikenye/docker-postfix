#!/usr/bin/with-contenv bash
# shellcheck shell=bash

POSTFIX_MASTERCF_FILE="/etc/postfix/master.cf"

# Do we enable & configure spf-engine?
if [ "${ENABLE_SPF}" = "true" ]; then
    echo "policy  unix  -       n       n       -       0       spawn" >> "${POSTFIX_MASTERCF_FILE}"
    echo "    user=nobody argv=/usr/local/lib/policyd-spf-perl" >> "${POSTFIX_MASTERCF_FILE}"
fi

# Do we enable & configure ClamAV?
if [ "${ENABLE_CLAMAV}" = "true" ]; then
    echo "scan  inet  "
fi