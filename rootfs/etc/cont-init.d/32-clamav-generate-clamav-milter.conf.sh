#!/usr/bin/with-contenv bash
# shellcheck shell=bash

CLAMAV_MILTERCONF_FILE="/usr/local/etc/clamav-milter.conf"

echo "" > "${CLAMAV_MILTERCONF_FILE}"

echo "MilterSocket inet:7357@localhost" >> "${CLAMAV_MILTERCONF_FILE}"
echo "User clamav" >> "${CLAMAV_MILTERCONF_FILE}"
echo "Foreground yes" >> "${CLAMAV_MILTERCONF_FILE}"
echo "PidFile /run/clamav-milter/clamav-milter.pid" >> "${CLAMAV_MILTERCONF_FILE}"
echo "TemporaryDirectory /tmp" >> "${CLAMAV_MILTERCONF_FILE}"
echo "ClamdSocket tcp:127.0.0.1:7358" >> "${CLAMAV_MILTERCONF_FILE}"
echo "OnInfected Blackhole" >> "${CLAMAV_MILTERCONF_FILE}"
echo "AddHeader yes" >> "${CLAMAV_MILTERCONF_FILE}"

# If CLAMAV_MILTER_REPORT_HOSTNAME, then set
if [ ! -z "${CLAMAV_MILTER_REPORT_HOSTNAME}" ]; then
    echo "ReportHostname ${CLAMAV_MILTER_REPORT_HOSTNAME}" >> "${CLAMAV_MILTERCONF_FILE}"
fi

echo "LogSyslog yes" >> "${CLAMAV_MILTERCONF_FILE}"
echo "LogRotate no" >> "${CLAMAV_MILTERCONF_FILE}"
echo "SupportMultipleRecipients yes" >> "${CLAMAV_MILTERCONF_FILE}"

# Troubleshooting
echo "ReadTimeout 300" >> "${CLAMAV_MILTERCONF_FILE}"
echo "LogVerbose yes" >> "${CLAMAV_MILTERCONF_FILE}"
echo "LogClean Full" >> "${CLAMAV_MILTERCONF_FILE}"
echo "LogInfected Full" >> "${CLAMAV_MILTERCONF_FILE}"
