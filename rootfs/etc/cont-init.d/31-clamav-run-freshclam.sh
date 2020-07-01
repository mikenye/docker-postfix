#!/usr/bin/with-contenv bash
# shellcheck shell=bash

echo "Updating ClamAV Database..."
if [ "${ENABLE_CLAMAV}" = "true" ]; then
    freshclam --stdout --foreground
fi
echo "ClamAV Database updated!"