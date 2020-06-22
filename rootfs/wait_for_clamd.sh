#!/usr/bin/env bash

unset PONG
while [ "$PONG" != "PONG" ]; do
    echo "Waiting for clamd to become ready..."
    PONG=$(echo "PING" | socat TCP-CONNECT:127.0.0.1:7358 - 2> /dev/null)
    sleep 1
done

echo "clamd is ready!"