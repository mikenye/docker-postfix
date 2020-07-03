#!/usr/bin/with-contenv bash
# shellcheck shell=bash

echo "Updating ClamAV Database..."
if [ "${ENABLE_CLAMAV}" = "true" ]; then
    freshclam --stdout --foreground --config-file="${CLAMAV_FRESHCLAMCONF_FILE}"
fi
echo "ClamAV Database updated!"