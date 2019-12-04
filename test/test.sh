#!/bin/sh

set -e

CONTAINER_IP=$(docker inspect --format '{{.NetworkSettings.IPAddress}}' unbound)

dig google.fr @$CONTAINER_IP
