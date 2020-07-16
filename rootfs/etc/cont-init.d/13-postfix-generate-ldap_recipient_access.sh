#!/usr/bin/with-contenv bash
# shellcheck shell=bash

echo "" > "${POSTFIX_LDAP_RECIPIENT_ACCESS_CONF_FILE}"

if [ "${ENABLE_LDAP_RECIPIENT_ACCESS}" = "true" ]; then
  {
    echo "domain = ${POSTFIX_RELAY_DOMAINS}"
    echo "server_host = ${POSTFIX_LDAP_SERVERS}"
    echo "version = ${POSTFIX_LDAP_VERSION}"
    echo "query_filter = ${POSTFIX_LDAP_QUERY_FILTER}"
    echo "search_base = ${POSTFIX_LDAP_SEARCH_BASE}"
    echo "bind = yes"
    echo "bind_dn = ${POSTFIX_LDAP_BIND_DN}"
    echo "bind_pw = ${POSTFIX_LDAP_BIND_PW}"
    echo "result_attribute = mail"
    echo "result_format = OK"
    echo "debuglevel = ${POSTFIX_LDAP_DEBUG_LEVEL}"
  } >> "${POSTFIX_LDAP_RECIPIENT_ACCESS_CONF_FILE}"
fi
