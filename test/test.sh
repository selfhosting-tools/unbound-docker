#!/bin/bash

set -e
set -o pipefail

CONTAINER_IP=$(docker inspect --format '{{.NetworkSettings.IPAddress}}' unbound)

dig google.fr @"$CONTAINER_IP" | grep NOERROR

dig dnssec-tools.org @"$CONTAINER_IP" | grep NOERROR
dig dnssec-tools.org @"$CONTAINER_IP" | grep ".*flags:.*ad.*"

dig dnssec-failed.org @"$CONTAINER_IP" | grep SERVFAIL
