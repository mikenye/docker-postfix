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

# Make postfix dirs
mkdir -p /var/spool/postfix/postscreen_cache
mkdir -p /var/spool/postfix/postgrey
mkdir -p /var/spool/postfix

# ClamAV
chown -R clamav:clamav /var/lib/clamav
chown -R clamav:clamav /run/freshclam
chown -R clamav:clamav /run/clamav-milter
chown -R clamav:clamav /run/clamd

# Postfix
chown root:root /var/spool/postfix
chown -R postfix /var/spool/postfix/active
chown -R postfix /var/spool/postfix/bounce
chown -R postfix /var/spool/postfix/corrupt
chown -R postfix /var/spool/postfix/defer
chown -R postfix /var/spool/postfix/deferred
chown -R postfix /var/spool/postfix/flush
chown -R postfix /var/spool/postfix/hold
chown -R postfix /var/spool/postfix/incoming
chown -R postfix:postdrop /var/spool/postfix/maildrop
chown -R root:root /var/spool/postfix/pid
chown -R postfix /var/spool/postfix/private
chown -R postfix /var/spool/postfix/public
chgrp postdrop /var/spool/postfix/public
chown -R postfix /var/spool/postfix/saved
chown -R postfix /var/spool/postfix/trace
chown -R postfix /var/spool/postfix/postscreen_cache

# OpenDKIM
chown -R opendkim /etc/mail/dkim

# Postgrey
chown -R postgrey /var/spool/postfix/postgrey
