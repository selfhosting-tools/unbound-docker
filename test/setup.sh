#!/bin/bash

set -e

# Build Docker image
docker build --no-cache -t ghcr.io/suvl/unbound:latest .

# Create test container
docker run \
    -d \
    --name unbound \
    -v "$(pwd)/test/resources":/etc/unbound \
    -t ghcr.io/suvl/unbound:latest

sleep 2

exit 0
