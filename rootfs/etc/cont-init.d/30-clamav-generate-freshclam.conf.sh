#!/usr/bin/with-contenv bash
# shellcheck shell=bash

{
    echo ""
    echo "DatabaseDirectory /var/lib/clamav"
    echo "LogSyslog no"
    echo "LogRotate no"
    echo "PidFile /run/freshclam/freshclam.pid"
    echo "DatabaseOwner clamav"
    echo "Foreground yes"
    echo "Bytecode yes"
    echo "DatabaseMirror database.clamav.net"
    echo "NotifyClamd /usr/local/etc/clamd.conf"

    if [ -n "${FRESHCLAM_CHECKS_PER_DAY}" ]; then
        echo "Checks ${FRESHCLAM_CHECKS_PER_DAY}"
    fi


} > "${CLAMAV_FRESHCLAMCONF_FILE}"
