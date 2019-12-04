#!/bin/bash

set -e

shellcheck bin/*.sh test/*.sh

hadolint Dockerfile
