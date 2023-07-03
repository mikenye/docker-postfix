#!/usr/bin/env bash

EXITCODE=0

# exit on error
set -e

echo "Start test env"
docker compose up -d

echo "Wait for container start (up to 5 mins)"
timeout 300s ./wait_for_postfix.sh

echo "Attempt to send email (may fail due to greylisting)"
./test_infected.expect 127.0.0.1 2525 remote.tld infectedtester@remote.tld testuser@mail.testdomain.tld || true

echo "Wait 10 mins for greylist timeout"
sleep 605

echo "Attempt to send email (should succeed)"
./test_infected.expect 127.0.0.1 2525 remote.tld infectedtester@remote.tld testuser@mail.testdomain.tld
sleep 2 # wait for postfix to deliver email

echo "Checking received email"
echo ""
docker exec mail_test touch /tmp/testuser_email
docker exec mail_test cat /tmp/testuser_email
if docker exec mail_test cat /tmp/testuser_email | grep 'From: infectedtester@remote.tld' > /dev/null 2>&1; then
    EXITCODE=1
fi

echo "Stop test env"
docker compose down

exit $EXITCODE
