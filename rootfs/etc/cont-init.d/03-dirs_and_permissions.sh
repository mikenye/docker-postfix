#!/usr/bin/with-contenv bash
# shellcheck shell=bash

# Make dirs
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

# Postgrey
chown -R postgrey /var/spool/postfix/postgrey
