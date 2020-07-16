#!/usr/bin/with-contenv bash
# shellcheck shell=bash

{
    echo "" 
    echo "LogSyslog no"
    echo "LogRotate no"
    echo "PidFile /run/clamd/clamd.pid"
    echo "TemporaryDirectory /tmp"
    echo "DatabaseDirectory /var/lib/clamav"
    echo "LocalSocket /run/clamd/clamd.socket"
    echo "TCPSocket 7358"
    echo "TCPAddr 127.0.0.1"
    echo "User clamav"
    echo "Foreground yes"

    if [ -n "${CLAMAV_CLAMD_PHISHING_SIGNATURES}" ]; then
        echo "PhishingSignatures ${CLAMAV_CLAMD_PHISHING_SIGNATURES}"
    fi

    if [ -n "${CLAMAV_CLAMD_PHISHING_SCAN_URLS}" ]; then
        echo "PhishingScanURLs ${CLAMAV_CLAMD_PHISHING_SCAN_URLS}"
    fi

    if [ -n "${CLAMAV_CLAMD_PHISHING_ALWAYS_BLOCK_SSL_MISMATCH}" ]; then
        echo "PhishingAlwaysBlockSSLMismatch ${CLAMAV_CLAMD_PHISHING_ALWAYS_BLOCK_SSL_MISMATCH}"
    fi

    if [ -n "${CLAMAV_CLAMD_PHISHING_ALWAYS_BLOCK_CLOAK}" ]; then
        echo "PhishingAlwaysBlockCloak ${CLAMAV_CLAMD_PHISHING_ALWAYS_BLOCK_CLOAK}"
    fi

    if [ -n "${CLAMAV_CLAMD_HEURISTIC_SCAN_PRECEDENCE}" ]; then
        echo "HeuristicScanPrecedence ${CLAMAV_CLAMD_HEURISTIC_SCAN_PRECEDENCE}"
    fi
} > "${CLAMAV_CLAMDCONF_FILE}"
