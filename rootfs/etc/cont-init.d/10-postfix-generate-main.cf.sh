#!/usr/bin/with-contenv bash
# shellcheck shell=bash

POSTFIX_MAINCF_FILE="/etc/postfix/main.cf"
echo "" > "${POSTFIX_MAINCF_FILE}"

SMTPDMILTERS=""

# http://www.postfix.org/postconf.5.html#enable_long_queue_ids
echo "enable_long_queue_ids = yes" >> "${POSTFIX_MAINCF_FILE}"

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

# http://www.postfix.org/postconf.5.html#relayhost
if [ ! -z "${POSTFIX_RELAYHOST}" ]; then
  echo "relayhost = ${POSTFIX_RELAYHOST}" >> "${POSTFIX_MAINCF_FILE}"
fi

# http://www.postfix.org/postconf.5.html#relay_domains
if [ ! -z "${POSTFIX_RELAY_DOMAINS}" ]; then
  echo "relay_domains = ${POSTFIX_RELAY_DOMAINS}" >> "${POSTFIX_MAINCF_FILE}"
fi

echo "disable_vrfy_command = yes" >> "${POSTFIX_MAINCF_FILE}"

echo "smtpd_hard_error_limit = 1" >> "${POSTFIX_MAINCF_FILE}"

echo "header_checks = pcre:/etc/postfix/header_checks.pcre" >> "${POSTFIX_MAINCF_FILE}"

# ========== START smtpd_helo_restrictions ==========

echo "smtpd_helo_required = yes" >> "${POSTFIX_MAINCF_FILE}"
echo "smtpd_helo_restrictions = " >> "${POSTFIX_MAINCF_FILE}"

  echo "    permit_mynetworks," >> "${POSTFIX_MAINCF_FILE}"

  echo "    check_helo_access hash:/etc/postfix/helo_access.hash," >> "${POSTFIX_MAINCF_FILE}"
  
  echo "    reject_invalid_helo_hostname," >> "${POSTFIX_MAINCF_FILE}"
  echo "    reject_non_fqdn_helo_hostname," >> "${POSTFIX_MAINCF_FILE}"
  echo "    reject_unknown_helo_hostname" >> "${POSTFIX_MAINCF_FILE}"

# ========== END smtpd_helo_restrictions ==========

# ========== START smtpd_recipient_restrictions ==========

echo "smtpd_recipient_restrictions = " >> "${POSTFIX_MAINCF_FILE}"
  echo "    permit_mynetworks," >> "${POSTFIX_MAINCF_FILE}"

  echo "    check_client_access cidr:/etc/postfix/client_access.cidr," >> "${POSTFIX_MAINCF_FILE}"

  if [ "${POSTFIX_SMTPD_RECIPIENT_RESTRICTIONS_PERMIT_SASL_AUTHENTICATED}" = "true" ]; then
    echo "    permit_sasl_authenticated," >> "${POSTFIX_MAINCF_FILE}"
  fi

    echo "    check_sender_access hash:/etc/postfix/sender_access.hash," >> "${POSTFIX_MAINCF_FILE}"

  echo "    reject_unauth_destination," >> "${POSTFIX_MAINCF_FILE}"

  if [ "${ENABLE_SPF}" = "true" ]; then
    echo "   check_policy_service unix:private/policy," >> "${POSTFIX_MAINCF_FILE}"
  fi

  echo "    reject_non_fqdn_recipient," >> "${POSTFIX_MAINCF_FILE}"
  echo "    reject_non_fqdn_sender," >> "${POSTFIX_MAINCF_FILE}"
  echo "    reject_unknown_sender_domain," >> "${POSTFIX_MAINCF_FILE}"
  echo "    reject_unknown_recipient_domain," >> "${POSTFIX_MAINCF_FILE}"

  if [ "${ENABLE_POSTGREY}" = "true" ]; then
    echo "    check_policy_service inet:127.0.0.1:10023," >> "${POSTFIX_MAINCF_FILE}"
  fi

  echo "    permit" >> "${POSTFIX_MAINCF_FILE}"

# ========== END smtpd_recipient_restrictions ==========

# ========== START smtpd_data_restrictions ==========

echo "smtpd_data_restrictions = " >> "${POSTFIX_MAINCF_FILE}"
  echo "    reject_unauth_pipelining,"  >> "${POSTFIX_MAINCF_FILE}"
  echo "    permit"  >> "${POSTFIX_MAINCF_FILE}"

# ========== END smtpd_data_restrictions ==========

# Do we enable & configure DKIM?
if [ "${ENABLE_OPENDKIM}" = "true" ]; then
  echo "milter_default_action = accept" >> "${POSTFIX_MAINCF_FILE}"
  echo "milter_protocol = 2" >> "${POSTFIX_MAINCF_FILE}"
  echo "non_smtpd_milters = inet:localhost:8891" >> "${POSTFIX_MAINCF_FILE}"
  if [ "$SMTPDMILTERS" = "" ]; then
    SMTPDMILTERS="inet:localhost:8891"
  else
    SMTPDMILTERS="$SMTPDMILTERS, inet:localhost:8891"
  fi
fi

# Do we enable & configure ClamAV?
if [ "${ENABLE_CLAMAV}" = "true" ]; then
  if [ "$SMTPDMILTERS" = "" ]; then
    SMTPDMILTERS="inet:localhost:7357"
  else
    SMTPDMILTERS="$SMTPDMILTERS, inet:localhost:7357"
  fi
fi

# Write milters
if [ "$SMTPDMILTERS" != "" ]; then
  # Troubleshooting
  echo "milter_command_timeout = 300s" >> "${POSTFIX_MAINCF_FILE}"
  
  echo "smtpd_milters = $SMTPDMILTERS" >> "${POSTFIX_MAINCF_FILE}"
fi

# ========== START postscreen config ==========

# http://www.postfix.org/postconf.5.html#message_size_limit
if [ ! -z "${POSTFIX_MESSAGE_SIZE_LIMIT}" ]; then
  echo "message_size_limit = ${POSTFIX_MESSAGE_SIZE_LIMIT}" >> "${POSTFIX_MAINCF_FILE}"
fi

# http://www.postfix.org/postconf.5.html#postscreen_access_list
echo "postscreen_access_list = " >> "${POSTFIX_MAINCF_FILE}"
  echo "    permit_mynetworks," >> "${POSTFIX_MAINCF_FILE}"
  echo "    cidr:/etc/postfix/postscreen_access.cidr" >> "${POSTFIX_MAINCF_FILE}"

# http://www.postfix.org/postconf.5.html#postscreen_blacklist_action
# TODO - once postscreen confirmed working properly, change to drop
echo "postscreen_blacklist_action = ignore" >> "${POSTFIX_MAINCF_FILE}"

# http://www.postfix.org/postconf.5.html#postscreen_dnsbl_sites
if [ ! -z "${POSTFIX_DNSBL_SITES}" ]; then
  echo "postscreen_dnsbl_sites = ${POSTFIX_DNSBL_SITES}" >> "${POSTFIX_MAINCF_FILE}"
  echo "postscreen_dnsbl_action = drop" >> "${POSTFIX_MAINCF_FILE}"
fi

# http://www.postfix.org/postconf.5.html#postscreen_dnsbl_threshold
if [ ! -z "${POSTFIX_DNSBL_THRESHOLD}" ]; then
  echo "postscreen_dnsbl_threshold = ${POSTFIX_DNSBL_THRESHOLD}" >> "${POSTFIX_MAINCF_FILE}"
fi

# http://www.postfix.org/postconf.5.html#postscreen_dnsbl_reply_map
if [ -f "${DNSBL_REPLY_TEXTHASH_FILE_LOCAL}" ]; then
  echo "postscreen_dnsbl_reply_map = texthash:/etc/postfix/dnsbl_reply.texthash" >> "${POSTFIX_MAINCF_FILE}"
fi

# http://www.postfix.org/postconf.5.html#postscreen_greet_action
# TODO - once postscreen confirmed working properly, change to drop
echo "postscreen_greet_action = drop" >> "${POSTFIX_MAINCF_FILE}"

# ========== END postscreen config ==========