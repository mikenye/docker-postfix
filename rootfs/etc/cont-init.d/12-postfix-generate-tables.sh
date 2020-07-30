#!/usr/bin/env bash
# shellcheck shell=bash

set -x

/usr/local/bin/update_body_checks
/usr/local/bin/update_client_access
/usr/local/bin/update_dnsbl_reply
/usr/local/bin/update_header_checks
/usr/local/bin/update_helo_access
/usr/local/bin/update_milter_header_checks
/usr/local/bin/update_postscreen_access
/usr/local/bin/update_recipient_access
/usr/local/bin/update_sender_access
