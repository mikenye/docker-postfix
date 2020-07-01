#!/usr/bin/with-contenv bash
# shellcheck shell=bash

POSTFIX_MASTERCF_FILE="/etc/postfix/master.cf"
POSTFIX_MASTERCF_ORIGINAL_FILE=" /etc/postfix/master.cf.original"

# Refresh the master.cf. This prevents duplicate entries on container restart
cat "${POSTFIX_MASTERCF_ORIGINAL_FILE}" > ${POSTFIX_MASTERCF_FILE}

# Do we enable & configure spf-engine?
if [ "${ENABLE_SPF}" = "true" ]; then
    echo "policy  unix  -       n       n       -       0       spawn" >> "${POSTFIX_MASTERCF_FILE}"
    echo "    user=nobody argv=/usr/local/lib/policyd-spf-perl" >> "${POSTFIX_MASTERCF_FILE}"
fi
