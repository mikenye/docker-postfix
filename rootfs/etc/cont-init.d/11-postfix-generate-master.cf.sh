#!/usr/bin/with-contenv bash
# shellcheck shell=bash

POSTFIX_MASTERCF_FILE="/etc/postfix/master.cf"
POSTFIX_MASTERCF_ORIGINAL_FILE="/etc/postfix/master.cf.original"

# Refresh the master.cf. This prevents duplicate entries on container restart
cp -v ${POSTFIX_MASTERCF_ORIGINAL_FILE} ${POSTFIX_MASTERCF_FILE}

# Enable postscreen
# See: http://www.postfix.org/POSTSCREEN_README.html
# Comment out the "smtp inet ... smtpd" service in master.cf
sed -i 's/^smtp *inet.*smtpd$/#&/' $POSTFIX_MASTERCF_FILE
# Uncomment the new "smtpd pass ... smtpd" service in master.cf
sed -i '/^#smtpd *pass.*smtpd$/s/^#//g' $POSTFIX_MASTERCF_FILE
# Uncomment the new "smtp inet ... postscreen" service in master.cf
sed -i '/^#smtp *inet.*postscreen$/s/^#//g' $POSTFIX_MASTERCF_FILE
# Uncomment the new "tlsproxy unix ... tlsproxy" service in master.cf
sed -i '/^#tlsproxy *unix.*tlsproxy$/s/^#//g' $POSTFIX_MASTERCF_FILE
# Uncomment the new "dnsblog unix ... dnsblog" service in master.cf
sed -i '/^#dnsblog *unix.*dnsblog$/s/^#//g' $POSTFIX_MASTERCF_FILE

# Do we enable & configure spf-engine?
if [ "${ENABLE_SPF}" = "true" ]; then
    echo "policy  unix  -       n       n       -       0       spawn" >>"${POSTFIX_MASTERCF_FILE}"
    echo "    user=nobody argv=/usr/local/lib/policyd-spf-perl" >>"${POSTFIX_MASTERCF_FILE}"
fi

# Please note that on Debian submission port (587) and smtps port (465) are called
# "submission" and "submissions" either in /etc/postfix/master.cf and in /etc/services
# Do we enable & configure submission port?
if [ "${ENABLE_SUBMISSION_PORT}" = "true" ]; then
    sed -i '/^#submission *inet.*smtpd$/s/^#//g' $POSTFIX_MASTERCF_FILE
fi
# Do we enable & configure smtps port?
if [ "${ENABLE_SMTPS_PORT}" = "true" ]; then
    sed -i '/^#submissions *inet.*smtpd$/s/^#//g' $POSTFIX_MASTERCF_FILE
fi
