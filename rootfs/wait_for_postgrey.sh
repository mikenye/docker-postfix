#!/usr/bin/env bash

unset EXITCODE
EXITCODE=1
while [ "$EXITCODE" -ne "0" ]; do
    echo "Waiting for postgrey to become ready..."
    echo "" | socat TCP-CONNECT:127.0.0.1:10023 -
    EXITCODE=$?
    sleep 2
done

echo "postgrey is ready!"