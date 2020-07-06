#!/usr/bin/with-contenv bash
# shellcheck shell=bash

# echo "" > "${CLAMSMTPD_CONF_FILE}"

# echo "OutAddress: 127.0.0.1:10026" >> "${CLAMSMTPD_CONF_FILE}"
# echo "Listen: 127.0.0.1:10025" >> "${CLAMSMTPD_CONF_FILE}"
# echo "ClamAddress: 127.0.0.1:7358" >> "${CLAMSMTPD_CONF_FILE}"
# echo "Header: X-Virus-Scanned: $(clamd --version) (using $(clamsmtpd -v | grep version | tr -d '(' | tr -d ')' | sed 's/version //g')) at %d" >> "${CLAMSMTPD_CONF_FILE}"
# echo "TempDirectory: /var/spool/postfix/clamsmtp" >> "${CLAMSMTPD_CONF_FILE}"
# echo "PidFile: /run/clamsmtpd/clamsmtpd.pid" >> "${CLAMSMTPD_CONF_FILE}"
# echo "Action: drop" >> "${CLAMSMTPD_CONF_FILE}"
# echo "TempDirectory: /tmp/clamsmtpd" >> "${CLAMSMTPD_CONF_FILE}"
# echo "TimeOut: 300" >> "${CLAMSMTPD_CONF_FILE}"
# echo "TransparentProxy: off" >> "${CLAMSMTPD_CONF_FILE}"
# echo "User: clamav" >> "${CLAMSMTPD_CONF_FILE}"
