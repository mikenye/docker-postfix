#!/usr/bin/with-contenv bash
# shellcheck shell=bash

CLAMAV_MILTERCONF_FILE="/usr/local/etc/clamav-milter.conf"

echo "" > "${CLAMAV_MILTERCONF_FILE}"

echo "MilterSocket /run/clamav-milter/clamav-milter.socket" >> "${CLAMAV_MILTERCONF_FILE}"
echo "User clamav" >> "${CLAMAV_MILTERCONF_FILE}"
echo "Foreground yes" >> "${CLAMAV_MILTERCONF_FILE}"
echo "PidFile /run/clamav-milter/clamav-milter.pid" >> "${CLAMAV_MILTERCONF_FILE}"
echo "TemporaryDirectory /tmp" >> "${CLAMAV_MILTERCONF_FILE}"
echo "ClamdSocket unix:/run/clamd/clamd.socket" >> "${CLAMAV_MILTERCONF_FILE}"
echo "OnInfected Blackhole" >> "${CLAMAV_MILTERCONF_FILE}"
echo "AddHeader yes" >> "${CLAMAV_MILTERCONF_FILE}"
echo "LogSyslog no" >> "${CLAMAV_MILTERCONF_FILE}"
echo "LogRotate no" >> "${CLAMAV_MILTERCONF_FILE}"
