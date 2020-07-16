#!/usr/bin/with-contenv bash
# shellcheck shell=bash

OPENDKIM_CONF_FILE="/etc/opendkim.conf"
echo "" > "${OPENDKIM_CONF_FILE}"

echo "Syslog true" >> "${OPENDKIM_CONF_FILE}"

# LogResults
if [ -n "${OPENDKIM_LOGRESULTS}" ]; then
    echo "LogResults true" >> "${OPENDKIM_CONF_FILE}"
fi

# LogWhy
if [ -n "${OPENDKIM_LOGWHY}" ]; then
    echo "LogWhy true" >> "${OPENDKIM_CONF_FILE}"
fi

# Listen on localhost:8891
echo "Socket inet:8891@127.0.0.1" >> "${OPENDKIM_CONF_FILE}"

# Run with same UID as postfix
echo "UserID opendkim" >> "${OPENDKIM_CONF_FILE}"

# Set domains that we sign for
if [ -n "${OPENDKIM_DOMAIN}" ]; then
    echo "Domain ${OPENDKIM_DOMAIN}" >> "${OPENDKIM_CONF_FILE}"
fi

# Specify signing table
if [ -n "${OPENDKIM_SIGNINGTABLE}" ]; then
    echo "SigningTable refile:${OPENDKIM_SIGNINGTABLE}" >> "${OPENDKIM_CONF_FILE}"
fi

# Specify key file
if [ -n "${OPENDKIM_KEYFILE}" ]; then
    echo "KeyFile ${OPENDKIM_KEYFILE}" >> "${OPENDKIM_CONF_FILE}"
fi

# Specify key table
if [ -n "${OPENDKIM_KEYTABLE}" ]; then
    echo "KeyTable refile:${OPENDKIM_KEYTABLE}" >> "${OPENDKIM_CONF_FILE}"
fi

# Set selector
if [ -n "${OPENDKIM_SELECTOR}" ]; then
    echo "Selector ${OPENDKIM_SELECTOR}" >> "${OPENDKIM_CONF_FILE}"
fi

# Set mode
if [ -n "${OPENDKIM_MODE}" ]; then
    echo "Mode ${OPENDKIM_MODE}" >> "${OPENDKIM_CONF_FILE}"
fi

# Autorestart is handled by s6-overlay, so set to false
echo "AutoRestart false" >> "${OPENDKIM_CONF_FILE}"

# We want this to stay in foreground for s6-overlay
echo "Background false" >> "${OPENDKIM_CONF_FILE}"

# Set internalhosts (hosts for which to sign for)
if [ -n "${OPENDKIM_INTERNALHOSTS}" ]; then
    echo "InternalHosts ${OPENDKIM_INTERNALHOSTS}" >> "${OPENDKIM_CONF_FILE}"
fi

# Set canonicalization
echo "Canonicalization relaxed/relaxed" >> "${OPENDKIM_CONF_FILE}"

# Sign subdomains?
if [ -n "${OPENDKIM_SUBDOMAINS}" ]; then
    echo "SubDomains ${OPENDKIM_SUBDOMAINS}" >> "${OPENDKIM_CONF_FILE}"
fi
