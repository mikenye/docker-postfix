#!/usr/bin/env bash

until docker compose logs mail_test | grep "the Postfix mail system is running" > /dev/null; do
    echo -n "."
    sleep 1
done

echo "OK"

