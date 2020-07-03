#!/usr/bin/env bash

unset PONG
while [ "$PONG" != "PONG" ]; do
    echo "Waiting for clamsmtpd to become ready..."
    PONG=$(echo "NOOP" | socat TCP-CONNECT:127.0.0.1:10025 - 2> /dev/null)
    sleep 2
done

echo "clamsmtpd is ready!"