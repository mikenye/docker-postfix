#!/usr/bin/with-contenv bash
# shellcheck shell=bash

POSTFIX_MAINCF_FILE="/etc/postfix/main.cf"
echo "" > "${POSTFIX_MAINCF_FILE}"

# Logging to stdout: http://www.postfix.org/MAILLOG_README.html
echo "maillog_file = /dev/stdout" >> "${POSTFIX_MAINCF_FILE}"

# http://www.postfix.org/postconf.5.html#compatibility_level
echo "compatibility_level = 2" >> "${POSTFIX_MAINCF_FILE}"

# http://www.postfix.org/postconf.5.html#alias_maps
echo "alias_maps = hash:/etc/aliases" >> "${POSTFIX_MAINCF_FILE}"

# http://www.postfix.org/postconf.5.html#myorigin
if [ ! -z "${POSTFIX_MYORIGIN}" ]; then
  echo "myorigin = ${POSTFIX_MYORIGIN}" >> "${POSTFIX_MAINCF_FILE}"
fi

# http://www.postfix.org/postconf.5.html#proxy_interfaces
if [ ! -z "${POSTFIX_PROXY_INTERFACES}" ]; then
  echo "proxy_interfaces = ${POSTFIX_PROXY_INTERFACES}" >> "${POSTFIX_MAINCF_FILE}"
fi

# http://www.postfix.org/postconf.5.html#mynetworks
if [ ! -z "${POSTFIX_MYNETWORKS}" ]; then
  echo "mynetworks = ${POSTFIX_MYNETWORKS}" >> "${POSTFIX_MAINCF_FILE}"
fi

# http://www.postfix.org/postconf.5.html#inet_protocols
if [ ! -z "${POSTFIX_INET_PROTOCOLS}" ]; then
  echo "inet_protocols = ${POSTFIX_INET_PROTOCOLS}" >> "${POSTFIX_MAINCF_FILE}"
fi

# http://www.postfix.org/postconf.5.html#mydomain
if [ ! -z "${POSTFIX_MYDOMAIN}" ]; then
  echo "mydomain = ${POSTFIX_MYDOMAIN}" >> "${POSTFIX_MAINCF_FILE}"
fi

# http://www.postfix.org/postconf.5.html#myhostname
if [ ! -z "${POSTFIX_MYHOSTNAME}" ]; then
  echo "myhostname = ${POSTFIX_MYHOSTNAME}" >> "${POSTFIX_MAINCF_FILE}"
fi

# http://www.postfix.org/postconf.5.html#mail_name
if [ ! -z "${POSTFIX_MAIL_NAME}" ]; then
  echo "mail_name = ${POSTFIX_MAIL_NAME}" >> "${POSTFIX_MAINCF_FILE}"
fi

# http://www.postfix.org/postconf.5.html#smtpd_tls_cert_file
if [ ! -z "${POSTFIX_SMTPD_TLS_CERT_FILE}" ]; then
  echo "smtpd_tls_cert_file = ${POSTFIX_SMTPD_TLS_CERT_FILE}" >> "${POSTFIX_MAINCF_FILE}"
fi

# http://www.postfix.org/postconf.5.html#smtpd_tls_key_file
if [ ! -z "${POSTFIX_SMTPD_TLS_KEY_FILE}" ]; then
  echo "smtpd_tls_key_file = ${POSTFIX_SMTPD_TLS_KEY_FILE}" >> "${POSTFIX_MAINCF_FILE}"
fi

# http://www.postfix.org/postconf.5.html#smtpd_tls_security_level
if [ ! -z "${POSTFIX_SMTPD_TLS_SECURITY_LEVEL}" ]; then
  echo "smtpd_tls_security_level = ${POSTFIX_SMTPD_TLS_SECURITY_LEVEL}" >> "${POSTFIX_MAINCF_FILE}"
fi

# http://www.postfix.org/postconf.5.html#smtpd_use_tls
if [ ! -z "${POSTFIX_SMTPD_USE_TLS}" ]; then
  echo "smtpd_use_tls = ${POSTFIX_SMTPD_USE_TLS}" >> "${POSTFIX_MAINCF_FILE}"
fi

# http://www.postfix.org/postconf.5.html#smtpd_tls_loglevel
if [ ! -z "${POSTFIX_SMTPD_TLS_LOGLEVEL}" ]; then
  echo "smtpd_tls_loglevel = ${POSTFIX_SMTPD_TLS_LOGLEVEL}" >> "${POSTFIX_MAINCF_FILE}"
fi

# http://www.postfix.org/postconf.5.html#smtp_tls_chain_files
if [ ! -z "${POSTFIX_SMTP_TLS_CHAIN_FILES}" ]; then
  echo "smtp_tls_chain_files = ${POSTFIX_SMTP_TLS_CHAIN_FILES}" >> "${POSTFIX_MAINCF_FILE}"
fi

# http://www.postfix.org/postconf.5.html#smtpd_tls_chain_files
if [ ! -z "${POSTFIX_SMTPD_TLS_CHAIN_FILES}" ]; then
  echo "smtpd_tls_chain_files = ${POSTFIX_SMTPD_TLS_CHAIN_FILES}" >> "${POSTFIX_MAINCF_FILE}"
fi

# Do we enable & configure DKIM?
if [ "${ENABLE_OPENDKIM}" = "true" ]; then
  echo "milter_default_action = accept" >> "${POSTFIX_MAINCF_FILE}"
  echo "milter_protocol = 2" >> "${POSTFIX_MAINCF_FILE}"
  echo "smtpd_milters = inet:localhost:8891" >> "${POSTFIX_MAINCF_FILE}"
  echo "non_smtpd_milters = inet:localhost:8891" >> "${POSTFIX_MAINCF_FILE}"
fi

# Do we enable & configure spf-engine
if [ "${ENABLE_SPF}" = "true" ]; then
  echo "policy-spf_time_limit = ${POSTFIX_POLICY_SPF_TIME_LIMIT}" >> "${POSTFIX_MAINCF_FILE}"
  echo "smtpd_recipient_restrictions = permit_mynetworks,permit_sasl_authenticated,reject_unauth_destination,check_policy_service unix:private/policy" >> "${POSTFIX_MAINCF_FILE}"
fi
