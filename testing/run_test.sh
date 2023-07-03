#!/usr/bin/env bash

# exit on error
set -e

echo "Start test env"
docker compose up -d

echo "Wait for container start (up to 5 mins)"
timeout 300s ./wait_for_postfix.sh

echo "Attempt to send email (will fail due to greylisting)"
../test_server.expect 127.0.0.1 2525 remote.tld tester@remote.tld testuser@mail.testdomain.tld || true

echo "Wait 5 mins for greylist timeout"
sleep 605

echo "Attempt to send email (should succeed)"
../test_server.expect 127.0.0.1 2525 remote.tld tester@remote.tld testuser@mail.testdomain.tld

echo "Checking received email"
echo ""
docker exec mail_test cat /tmp/testuser_email
docker exec mail_test cat /tmp/testuser_email | grep 'Return-Path: <tester@remote.tld>' > /dev/null 2>&1
docker exec mail_test cat /tmp/testuser_email | grep 'Delivered-To: testuser@mail.testdomain.tld' > /dev/null 2>&1
docker exec mail_test cat /tmp/testuser_email | grep 'X-Greylist: delayed' > /dev/null 2>&1
docker exec mail_test cat /tmp/testuser_email | grep 'Received: from remote.tld' > /dev/null 2>&1
docker exec mail_test cat /tmp/testuser_email | grep 'From: tester@remote.tld' > /dev/null 2>&1
docker exec mail_test cat /tmp/testuser_email | grep 'To: testuser@mail.testdomain.tld' > /dev/null 2>&1
docker exec mail_test cat /tmp/testuser_email | grep 'Subject: Test email sent at' > /dev/null 2>&1
docker exec mail_test cat /tmp/testuser_email | grep 'This is a test message set at date' > /dev/null 2>&1

echo "Stop test env"
docker compose down
