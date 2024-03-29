#!/usr/bin/env bash

# exit on error
set -e

echo "Start test env"
docker compose up -d

echo "Wait for container start (up to 5 mins)"
timeout 300s ./wait_for_postfix.sh

echo "Attempt to send email (may fail due to greylisting)"
./test_server.expect 127.0.0.1 2525 remote.tld tester@remote.tld testuser@mail.testdomain.tld || true

echo "Wait 10 mins for greylist timeout"
sleep 605

echo "Attempt to send email (should succeed)"
./test_server.expect 127.0.0.1 2525 remote.tld tester@remote.tld testuser@mail.testdomain.tld
sleep 2 # wait for postfix to deliver email

echo "Checking received email"
echo ""
docker exec mail_test cat /tmp/testuser_email
docker exec mail_test cat /tmp/testuser_email | grep 'Return-Path: <tester@remote.tld>'
docker exec mail_test cat /tmp/testuser_email | grep 'Delivered-To: testuser@mail.testdomain.tld'
docker exec mail_test cat /tmp/testuser_email | grep 'X-Greylist: delayed'
docker exec mail_test cat /tmp/testuser_email | grep 'Received: from remote.tld'
docker exec mail_test cat /tmp/testuser_email | grep 'From: tester@remote.tld'
docker exec mail_test cat /tmp/testuser_email | grep 'To: testuser@mail.testdomain.tld'
docker exec mail_test cat /tmp/testuser_email | grep 'Subject: Test email sent at'
docker exec mail_test cat /tmp/testuser_email | grep 'This is a test message sent at'

echo "Stop test env"
docker compose down
