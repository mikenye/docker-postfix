#!/usr/bin/env bash

until docker compose logs mail_test | grep "the Postfix mail system is running" > /dev/null; do
    echo "Waiting for postfix to start..."
    sleep 1
done

