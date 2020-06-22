#!/usr/bin/with-contenv bash
# shellcheck shell=bash

if [ "${ENABLE_CLAMAV}" = "true" ]; then
    freshclam --stdout --foreground
fi
