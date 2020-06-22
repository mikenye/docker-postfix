#!/usr/bin/env bash

echo "Waiting for clamd to become ready..."

unset PONG
while [ "$PONG" != "PONG" ]; do
    PONG=$(echo "PING" | socat TCP-CONNECT:127.0.0.1:7358 -)
    sleep 1
done
