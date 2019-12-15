#!/bin/bash

set -e

# Build Docker image
docker build --no-cache -t selfhostingtools/unbound:latest .

# Create test container
docker run \
    -d \
    --name unbound \
    -v "$(pwd)/test/resources":/etc/unbound \
    -t selfhostingtools/unbound:latest

sleep 2

exit 0
