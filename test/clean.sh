#!/bin/bash

set -e

docker container stop unbound || true
docker container rm --volumes unbound || true
docker images --quiet --filter=dangling=true | xargs --no-run-if-empty docker rmi
