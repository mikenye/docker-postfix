#!/usr/bin/with-contenv bash
# shellcheck shell=bash

{
    echo "MilterSocket inet:7357@localhost"
    echo "User clamav"
    echo "Foreground yes"
    echo "PidFile /run/clamav-milter/clamav-milter.pid"
    echo "TemporaryDirectory /tmp"
    echo "ClamdSocket tcp:127.0.0.1:7358"
    echo "OnInfected Blackhole"
    echo "AddHeader yes"
    echo "LogSyslog no"
    echo "LogRotate no"
    echo "SupportMultipleRecipients yes"
    echo "ReadTimeout 300"
    echo "LogClean Basic"
    echo "LogInfected Full"
} > "${CLAMAV_MILTERCONF_FILE}"

# If CLAMAV_MILTER_REPORT_HOSTNAME, then set
if [ ! -z "${CLAMAV_MILTER_REPORT_HOSTNAME}" ]; then
    echo "ReportHostname ${CLAMAV_MILTER_REPORT_HOSTNAME}" >> "${CLAMAV_MILTERCONF_FILE}"
fi
