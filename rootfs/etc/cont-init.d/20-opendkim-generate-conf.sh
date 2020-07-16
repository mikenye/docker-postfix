#!/usr/bin/with-contenv bash
# shellcheck shell=bash

OPENDKIM_CONF_FILE="/etc/opendkim.conf"

{
    echo "Syslog true"

    # LogResults
    if [ -n "${OPENDKIM_LOGRESULTS}" ]; then
        echo "LogResults true"
    fi

    # LogWhy
    if [ -n "${OPENDKIM_LOGWHY}" ]; then
        echo "LogWhy true"
    fi

    # Listen on localhost:8891
    echo "Socket inet:8891@127.0.0.1"

    # Run with same UID as postfix
    echo "UserID opendkim"

    # Set domains that we sign for
    if [ -n "${OPENDKIM_DOMAIN}" ]; then
        echo "Domain ${OPENDKIM_DOMAIN}"
    fi

    # Specify signing table
    if [ -n "${OPENDKIM_SIGNINGTABLE}" ]; then
        echo "SigningTable refile:${OPENDKIM_SIGNINGTABLE}"
    fi

    # Specify key file
    if [ -n "${OPENDKIM_KEYFILE}" ]; then
        echo "KeyFile ${OPENDKIM_KEYFILE}"
    fi

    # Specify key table
    if [ -n "${OPENDKIM_KEYTABLE}" ]; then
        echo "KeyTable refile:${OPENDKIM_KEYTABLE}"
    fi

    # Set selector
    if [ -n "${OPENDKIM_SELECTOR}" ]; then
        echo "Selector ${OPENDKIM_SELECTOR}"
    fi

    # Set mode
    if [ -n "${OPENDKIM_MODE}" ]; then
        echo "Mode ${OPENDKIM_MODE}"
    fi

    # Autorestart is handled by s6-overlay, so set to false
    echo "AutoRestart false"
    
    # We want this to stay in foreground for s6-overlay
    echo "Background false"

    # Set internalhosts (hosts for which to sign for)
    if [ -n "${OPENDKIM_INTERNALHOSTS}" ]; then
        echo "InternalHosts ${OPENDKIM_INTERNALHOSTS}"
    fi

    # Set canonicalization
    echo "Canonicalization relaxed/relaxed"

    # Sign subdomains?
    if [ -n "${OPENDKIM_SUBDOMAINS}" ]; then
        echo "SubDomains ${OPENDKIM_SUBDOMAINS}"
    fi

} > "${OPENDKIM_CONF_FILE}"