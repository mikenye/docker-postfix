#!/usr/bin/with-contenv bash
# shellcheck shell=bash

POSTFIX_MASTERCF_FILE="/etc/postfix/master.cf"
POSTFIX_MASTERCF_ORIGINAL_FILE="/etc/postfix/master.cf.original"

# Refresh the master.cf. This prevents duplicate entries on container restart
cp -v ${POSTFIX_MASTERCF_ORIGINAL_FILE} ${POSTFIX_MASTERCF_FILE}

# Enable postscreen
# See: http://www.postfix.org/POSTSCREEN_README.html
# Comment out the "smtp inet ... smtpd" service in master.cf
sed -i 's/^smtp *inet.*smtpd$/#&/' /etc/postfix/master.cf
# Uncomment the new "smtpd pass ... smtpd" service in master.cf
sed -i '/^#smtpd *pass.*smtpd$/s/^#//g' /etc/postfix/master.cf
# Uncomment the new "smtp inet ... postscreen" service in master.cf
sed -i '/^#smtp *inet.*postscreen$/s/^#//g' /etc/postfix/master.cf
# Uncomment the new "tlsproxy unix ... tlsproxy" service in master.cf
sed -i '/^#tlsproxy *unix.*tlsproxy$/s/^#//g' /etc/postfix/master.cf
# Uncomment the new "dnsblog unix ... dnsblog" service in master.cf
sed -i '/^#dnsblog *unix.*dnsblog$/s/^#//g' /etc/postfix/master.cf

# Do we enable & configure spf-engine?
if [ "${ENABLE_SPF}" = "true" ]; then
    echo "policy  unix  -       n       n       -       0       spawn" >> "${POSTFIX_MASTERCF_FILE}"
    echo "    user=nobody argv=/usr/local/lib/policyd-spf-perl" >> "${POSTFIX_MASTERCF_FILE}"
fi
