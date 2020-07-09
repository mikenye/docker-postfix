#!/usr/bin/with-contenv bash
# shellcheck shell=bash

echo "" > "${CLAMAV_FRESHCLAMCONF_FILE}"

echo "DatabaseDirectory /var/lib/clamav" >> "${CLAMAV_FRESHCLAMCONF_FILE}"
echo "LogSyslog no" >> "${CLAMAV_FRESHCLAMCONF_FILE}"
echo "LogRotate no" >> "${CLAMAV_FRESHCLAMCONF_FILE}"
echo "PidFile /run/freshclam/freshclam.pid" >> "${CLAMAV_FRESHCLAMCONF_FILE}"
echo "DatabaseOwner clamav" >> "${CLAMAV_FRESHCLAMCONF_FILE}"

if [ ! -z "${FRESHCLAM_CHECKS_PER_DAY}" ]; then
    echo "Checks ${FRESHCLAM_CHECKS_PER_DAY}" >> "${CLAMAV_FRESHCLAMCONF_FILE}"
fi

echo "Foreground yes" >> "${CLAMAV_FRESHCLAMCONF_FILE}"
echo "Bytecode yes" >> "${CLAMAV_FRESHCLAMCONF_FILE}"
echo "DatabaseMirror database.clamav.net" >> "${CLAMAV_FRESHCLAMCONF_FILE}"
echo "NotifyClamd /usr/local/etc/clamd.conf" >> "${CLAMAV_FRESHCLAMCONF_FILE}"
