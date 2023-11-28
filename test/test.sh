#!/bin/bash

set -e
set -o pipefail

CONTAINER_IP=$(docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' unbound)

dig google.pt @"$CONTAINER_IP" | grep NOERROR

dig dnssec-tools.org @"$CONTAINER_IP" | grep NOERROR
dig dnssec-tools.org @"$CONTAINER_IP" | grep ".*flags:.*ad.*"

dig dnssec-failed.org @"$CONTAINER_IP" | grep SERVFAIL
