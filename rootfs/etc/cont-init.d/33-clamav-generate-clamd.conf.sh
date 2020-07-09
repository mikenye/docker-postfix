#!/usr/bin/with-contenv bash
# shellcheck shell=bash

echo "" > "${CLAMAV_CLAMDCONF_FILE}"

echo "LogSyslog no" >> "${CLAMAV_CLAMDCONF_FILE}"
echo "LogRotate no" >> "${CLAMAV_CLAMDCONF_FILE}"
echo "PidFile /run/clamd/clamd.pid" >> "${CLAMAV_CLAMDCONF_FILE}"
echo "TemporaryDirectory /tmp" >> "${CLAMAV_CLAMDCONF_FILE}"
echo "DatabaseDirectory /var/lib/clamav" >> "${CLAMAV_CLAMDCONF_FILE}"
echo "LocalSocket /run/clamd/clamd.socket" >> "${CLAMAV_CLAMDCONF_FILE}"
echo "TCPSocket 7358" >> "${CLAMAV_CLAMDCONF_FILE}"
echo "TCPAddr 127.0.0.1" >> "${CLAMAV_CLAMDCONF_FILE}"
echo "User clamav" >> "${CLAMAV_CLAMDCONF_FILE}"
echo "Foreground yes" >> "${CLAMAV_CLAMDCONF_FILE}"
