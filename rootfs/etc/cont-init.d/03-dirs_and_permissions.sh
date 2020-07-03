#!/usr/bin/with-contenv bash
# shellcheck shell=bash

# Make log dirs
# Create log dir for piaware
mkdir -p /var/log/clamav-milter
chown nobody:nogroup /var/log/clamav-milter
mkdir -p /var/log/clamd
chown nobody:nogroup /var/log/clamd
mkdir -p /var/log/freshclam
chown nobody:nogroup /var/log/freshclam
mkdir -p /var/log/opendkim
chown nobody:nogroup /var/log/opendkim
mkdir -p /var/log/postfix
chown nobody:nogroup /var/log/postfix
mkdir -p /var/log/postgrey
chown nobody:nogroup /var/log/postgrey
mkdir -p /var/log/postgrey_whitelist_update
chown nobody:nogroup /var/log/postgrey_whitelist_update
mkdir -p /var/log/syslogd
chown nobody:nogroup /var/log/syslogd

# ClamAV
mkdir -p /var/lib/clamav
chown -R clamav:clamav /var/lib/clamav
mkdir -p /run/freshclam
chown -R clamav:clamav /run/freshclam
mkdir -p /run/clamav-milter
chown -R clamav:clamav /run/clamav-milter
mkdir -p /run/clamd
chown -R clamav:clamav /run/clamd

# Postfix
mkdir -p /var/spool/postfix
chown root:root /var/spool/postfix
mkdir -p /var/spool/postfix/active
chown -R postfix /var/spool/postfix/active
mkdir -p /var/spool/postfix/bounce
chown -R postfix /var/spool/postfix/bounce
mkdir -p /var/spool/postfix/corrupt
chown -R postfix /var/spool/postfix/corrupt
mkdir -p /var/spool/postfix/defer
chown -R postfix /var/spool/postfix/defer
mkdir -p /var/spool/postfix/deferred
chown -R postfix /var/spool/postfix/deferred
mkdir -p /var/spool/postfix/flush
chown -R postfix /var/spool/postfix/flush
mkdir -p /var/spool/postfix/hold
chown -R postfix /var/spool/postfix/hold
mkdir -p /var/spool/postfix/incoming
chown -R postfix /var/spool/postfix/incoming
mkdir -p /var/spool/postfix/maildrop
chown -R postfix:postdrop /var/spool/postfix/maildrop
mkdir -p /var/spool/postfix/pid
chown -R root:root /var/spool/postfix/pid
mkdir -p /var/spool/postfix/private
chown -R postfix /var/spool/postfix/private
mkdir -p /var/spool/postfix/public
chown -R postfix /var/spool/postfix/public
chgrp postdrop /var/spool/postfix/public
mkdir -p /var/spool/postfix/saved
chown -R postfix /var/spool/postfix/saved
mkdir -p /var/spool/postfix/trace
chown -R postfix /var/spool/postfix/trace

# ClamSMTPD
mkdir -p /var/spool/postfix/clamsmtp
chown -R clamav:clamav /var/spool/postfix/clamsmtp
mkdir -p /run/clamsmtpd
chown -R clamav:clamav /run/clamsmtpd
mkdir -p /tmp/clamsmtpd
chown -R clamav:clamav /tmp/clamsmtpd

# OpenDKIM
mkdir -p /etc/mail/dkim
chown -R opendkim /etc/mail/dkim

# Postgrey
mkdir -p /var/spool/postfix/postgrey
chown -R postgrey /var/spool/postfix/postgrey

