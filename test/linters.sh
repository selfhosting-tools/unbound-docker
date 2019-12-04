#!/bin/bash

set -e

shellcheck run.sh test/*.sh

hadolint Dockerfile
