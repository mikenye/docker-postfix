#!/usr/bin/with-contenv bash
# shellcheck shell=bash

OPENDKIM_CONF_FILE="/etc/opendkim.conf"
echo "" > "${OPENDKIM_CONF_FILE}"

# Don't log to syslog (there is no syslog in this container)
echo "Syslog false" >> "${OPENDKIM_CONF_FILE}"

# Listen on localhost:8891
echo "Socket inet:8891@127.0.0.1" >> "${OPENDKIM_CONF_FILE}"

# Run with same UID as postfix
echo "UserID $(id -u postfix)" >> "${OPENDKIM_CONF_FILE}"

# Set domains that we sign for
if [ ! -z "${OPENDKIM_DOMAIN}" ]; then
    echo "Domain ${OPENDKIM_DOMAIN}" >> "${OPENDKIM_CONF_FILE}"
fi

# Specify key file
if [ ! -z "${OPENDKIM_KEYFILE}" ]; then
    echo "KeyFile ${OPENDKIM_KEYFILE}" >> "${OPENDKIM_CONF_FILE}"
fi

# Set selector
echo "Selector mail" >> "${OPENDKIM_CONF_FILE}"

# Set mode
if [ ! -z "${OPENDKIM_MODE}" ]; then
    echo "Mode ${OPENDKIM_MODE}" >> "${OPENDKIM_CONF_FILE}"
fi

# Autorestart is handled by s6-overlay, so set to false
echo "AutoRestart false" >> "${OPENDKIM_CONF_FILE}"

# We want this to stay in foreground for s6-overlay
echo "Background false" >> "${OPENDKIM_CONF_FILE}"

# Set internalhosts (hosts for which to sign for)
if [ ! -z "${OPENDKIM_INTERNALHOSTS}" ]; then
    echo "InternalHosts ${OPENDKIM_INTERNALHOSTS}" >> "${OPENDKIM_CONF_FILE}"
fi

# Set canonicalization
echo "Canonicalization relaxed/relaxed" >> "${OPENDKIM_CONF_FILE}"

# Sign subdomains?
if [ ! -z "${OPENDKIM_SUBDOMAINS}" ]; then
    echo "SubDomains ${OPENDKIM_SUBDOMAINS}" >> "${OPENDKIM_CONF_FILE}"
fi
