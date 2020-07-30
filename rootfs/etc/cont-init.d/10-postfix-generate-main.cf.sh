#!/usr/bin/with-contenv bash
# shellcheck shell=bash

POSTFIX_MAINCF_FILE="/etc/postfix/main.cf"
SMTPDMILTERS=""
CHECK_RECIPIENT_ACCESS=""

{
  echo ""

  # http://www.postfix.org/postconf.5.html#enable_long_queue_ids
  echo "enable_long_queue_ids = yes"

  # Logging to stdout: http://www.postfix.org/MAILLOG_README.html
  echo "maillog_file = /dev/stdout"

  # http://www.postfix.org/postconf.5.html#compatibility_level
  echo "compatibility_level = 2"

  # http://www.postfix.org/postconf.5.html#alias_maps
  echo "alias_maps = hash:/etc/aliases"

  # http://www.postfix.org/SMTPUTF8_README.html
  if [ "${POSTFIX_SMTPUTF8_ENABLE}" = "true" ]; then
    echo "smtputf8_enable = yes"
  fi

  # http://www.postfix.org/postconf.5.html#myorigin
  if [ -n "${POSTFIX_MYORIGIN}" ]; then
    echo "myorigin = ${POSTFIX_MYORIGIN}"
  fi

  # http://www.postfix.org/postconf.5.html#proxy_interfaces
  if [ -n "${POSTFIX_PROXY_INTERFACES}" ]; then
    echo "proxy_interfaces = ${POSTFIX_PROXY_INTERFACES}"
  fi

  # http://www.postfix.org/postconf.5.html#mynetworks
  if [ -n "${POSTFIX_MYNETWORKS}" ]; then
    echo "mynetworks = ${POSTFIX_MYNETWORKS}"
  fi

  # http://www.postfix.org/postconf.5.html#inet_protocols
  if [ -n "${POSTFIX_INET_PROTOCOLS}" ]; then
    echo "inet_protocols = ${POSTFIX_INET_PROTOCOLS}"
  fi

  # http://www.postfix.org/postconf.5.html#mydomain
  if [ -n "${POSTFIX_MYDOMAIN}" ]; then
    echo "mydomain = ${POSTFIX_MYDOMAIN}"
  fi

  # http://www.postfix.org/postconf.5.html#myhostname
  if [ -n "${POSTFIX_MYHOSTNAME}" ]; then
    echo "myhostname = ${POSTFIX_MYHOSTNAME}"
  fi

  # http://www.postfix.org/postconf.5.html#mail_name
  if [ -n "${POSTFIX_MAIL_NAME}" ]; then
    echo "mail_name = ${POSTFIX_MAIL_NAME}"
  fi

  # http://www.postfix.org/postconf.5.html#smtpd_tls_cert_file
  if [ -n "${POSTFIX_SMTPD_TLS_CERT_FILE}" ]; then
    echo "smtpd_tls_cert_file = ${POSTFIX_SMTPD_TLS_CERT_FILE}"
  fi

  # http://www.postfix.org/postconf.5.html#smtpd_tls_key_file
  if [ -n "${POSTFIX_SMTPD_TLS_KEY_FILE}" ]; then
    echo "smtpd_tls_key_file = ${POSTFIX_SMTPD_TLS_KEY_FILE}"
  fi

  # http://www.postfix.org/postconf.5.html#smtpd_tls_security_level
  if [ -n "${POSTFIX_SMTPD_TLS_SECURITY_LEVEL}" ]; then
    echo "smtpd_tls_security_level = ${POSTFIX_SMTPD_TLS_SECURITY_LEVEL}"
  fi

  # http://www.postfix.org/postconf.5.html#smtpd_use_tls
  if [ -n "${POSTFIX_SMTPD_USE_TLS}" ]; then
    echo "smtpd_use_tls = ${POSTFIX_SMTPD_USE_TLS}"
  fi

  # http://www.postfix.org/postconf.5.html#smtpd_tls_loglevel
  if [ -n "${POSTFIX_SMTPD_TLS_LOGLEVEL}" ]; then
    echo "smtpd_tls_loglevel = ${POSTFIX_SMTPD_TLS_LOGLEVEL}"
  fi

  # http://www.postfix.org/postconf.5.html#smtp_tls_chain_files
  if [ -n "${POSTFIX_SMTP_TLS_CHAIN_FILES}" ]; then
    echo "smtp_tls_chain_files = ${POSTFIX_SMTP_TLS_CHAIN_FILES}"
  fi

  # http://www.postfix.org/postconf.5.html#smtpd_tls_chain_files
  if [ -n "${POSTFIX_SMTPD_TLS_CHAIN_FILES}" ]; then
    echo "smtpd_tls_chain_files = ${POSTFIX_SMTPD_TLS_CHAIN_FILES}"
  fi

  # http://www.postfix.org/postconf.5.html#relayhost
  if [ -n "${POSTFIX_RELAYHOST}" ]; then
    echo "relayhost = ${POSTFIX_RELAYHOST}:${POSTFIX_RELAYHOST_PORT}"
  fi

  # http://www.postfix.org/postconf.5.html#relay_domains
  if [ -n "${POSTFIX_RELAY_DOMAINS}" ]; then
    echo "relay_domains = ${POSTFIX_RELAY_DOMAINS}"
  fi

  echo "disable_vrfy_command = yes"

  echo "smtpd_hard_error_limit = 1"

  echo "header_checks = pcre:/etc/postfix/header_checks.pcre"
  echo "milter_header_checks = pcre:/etc/postfix/milter_header_checks.pcre"

  # ========== START smtpd_helo_restrictions ==========

  echo "smtpd_helo_required = yes"
  echo "smtpd_helo_restrictions = "
  echo "    permit_mynetworks,"
  echo "    check_helo_access hash:/etc/postfix/helo_access.hash,"
    
    if [ "${POSTFIX_REJECT_INVALID_HELO_HOSTNAME}" = "true" ]; then
      echo "    reject_invalid_helo_hostname,"
    fi

    if [ "${POSTFIX_REJECT_NON_FQDN_HELO_HOSTNAME}" = "true" ]; then
      echo "    reject_non_fqdn_helo_hostname,"
    fi

    if [ "${POSTFIX_REJECT_UNKNOWN_HELO_HOSTNAME}" = "true" ]; then
      echo "    reject_unknown_helo_hostname"
    fi

  # ========== END smtpd_helo_restrictions ==========

  # ========== START smtpd_recipient_restrictions ==========

  echo "smtpd_recipient_restrictions = "
    echo "    permit_mynetworks,"

    echo "    check_client_access cidr:/etc/postfix/client_access.cidr,"

    if [ "${POSTFIX_SMTPD_RECIPIENT_RESTRICTIONS_PERMIT_SASL_AUTHENTICATED}" = "true" ]; then
      echo "    permit_sasl_authenticated,"
    fi

    echo "    check_sender_access hash:/etc/postfix/sender_access.hash,"

    echo "    reject_unauth_destination,"

    if [ "${ENABLE_SPF}" = "true" ]; then
      echo "    check_policy_service unix:private/policy,"
    fi

    echo "    reject_non_fqdn_recipient,"
    echo "    reject_non_fqdn_sender,"
    echo "    reject_unknown_sender_domain,"
    echo "    reject_unknown_recipient_domain,"

    if [ "${ENABLE_POSTGREY}" = "true" ]; then
      echo "    check_policy_service inet:127.0.0.1:10023,"
    fi

    # If local recipient_access.hash file exists, add to check_recipient_access 
    if [ -f "/etc/postfix/tables/recipient_access.hash" ]; then
      if [ "$CHECK_RECIPIENT_ACCESS" = "" ]; then
        CHECK_RECIPIENT_ACCESS="hash:/etc/postfix/recipient_access.hash"
      else
        CHECK_RECIPIENT_ACCESS="$CHECK_RECIPIENT_ACCESS, hash:/etc/postfix/recipient_access.hash"
      fi
    fi

    # If ENABLE_LDAP_RECIPIENT_ACCESS, then add ldap to check_recipient_access
    if [ "${ENABLE_LDAP_RECIPIENT_ACCESS}" = "true" ]; then
      if [ "$CHECK_RECIPIENT_ACCESS" = "" ]; then
        CHECK_RECIPIENT_ACCESS="ldap:${POSTFIX_LDAP_RECIPIENT_ACCESS_CONF_FILE}"
      else
        CHECK_RECIPIENT_ACCESS="$CHECK_RECIPIENT_ACCESS, ldap:${POSTFIX_LDAP_RECIPIENT_ACCESS_CONF_FILE}"
      fi
    fi

    if [ "${CHECK_RECIPIENT_ACCESS}" != "" ]; then
      echo "    check_recipient_access ${CHECK_RECIPIENT_ACCESS},"
      echo "    $POSTFIX_CHECK_RECIPIENT_ACCESS_FINAL_ACTION"

    else
      echo "    permit"
    fi

  # ========== END smtpd_recipient_restrictions ==========

  # ========== START smtpd_data_restrictions ==========

  echo "smtpd_data_restrictions = "
    echo "    reject_unauth_pipelining,"
    echo "    permit"

  # ========== END smtpd_data_restrictions ==========

  # Do we enable & configure DKIM?
  if [ "${ENABLE_OPENDKIM}" = "true" ]; then
    echo "milter_default_action = accept"
    echo "milter_protocol = 2"
    echo "non_smtpd_milters = inet:localhost:8891"

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

  # Are there any extra smtpd milters? If so, write 'em.
  if [ -n "${POSTFIX_SMTPD_MILTERS}" ]; then
    if [ "$SMTPDMILTERS" = "" ]; then
      SMTPDMILTERS="${POSTFIX_SMTPD_MILTERS}"
    else
      SMTPDMILTERS="$SMTPDMILTERS, ${POSTFIX_SMTPD_MILTERS}"
    fi
  fi

  # Write milters
  if [ "$SMTPDMILTERS" != "" ]; then
    echo "milter_command_timeout = 300s"
    echo "smtpd_milters = $SMTPDMILTERS"
  fi

  # ========== START postscreen config ==========

  # http://www.postfix.org/postconf.5.html#message_size_limit
  if [ -n "${POSTFIX_MESSAGE_SIZE_LIMIT}" ]; then
    echo "message_size_limit = ${POSTFIX_MESSAGE_SIZE_LIMIT}"
  fi

  # http://www.postfix.org/postconf.5.html#postscreen_access_list
  echo "postscreen_access_list = "
    echo "    permit_mynetworks,"
    echo "    cidr:/etc/postfix/postscreen_access.cidr"

  # http://www.postfix.org/postconf.5.html#postscreen_blacklist_action
  # TODO - once postscreen confirmed working properly, change to drop
  echo "postscreen_blacklist_action = ignore"

  # http://www.postfix.org/postconf.5.html#postscreen_dnsbl_sites
  if [ -n "${POSTFIX_DNSBL_SITES}" ]; then
    echo "postscreen_dnsbl_sites = ${POSTFIX_DNSBL_SITES}"
    echo "postscreen_dnsbl_action = drop"
  fi

  # http://www.postfix.org/postconf.5.html#postscreen_dnsbl_threshold
  if [ -n "${POSTFIX_DNSBL_THRESHOLD}" ]; then
    echo "postscreen_dnsbl_threshold = ${POSTFIX_DNSBL_THRESHOLD}"
  fi

  # http://www.postfix.org/postconf.5.html#postscreen_dnsbl_reply_map
  if [ -f "/etc/postfix/tables/dnsbl_reply.texthash" ]; then
    echo "postscreen_dnsbl_reply_map = texthash:/etc/postfix/dnsbl_reply.texthash"
  fi

  # http://www.postfix.org/postconf.5.html#postscreen_greet_action
  # TODO - once postscreen confirmed working properly, change to drop
  echo "postscreen_greet_action = drop"

  # ========== END postscreen config ==========

  echo "body_checks = pcre:/etc/postfix/body_checks.pcre"

} > "${POSTFIX_MAINCF_FILE}"