# selfhosting-tools/unbound-docker

![Github Actions](https://github.com/selfhosting-tools/unbound-docker/workflows/main/badge.svg?branch=master)
[![Project Status: Active  The project has reached a stable, usable state and is being actively developed.](https://www.repostatus.org/badges/latest/active.svg)](https://www.repostatus.org/#active)
[![Docker Hub](https://img.shields.io/docker/pulls/selfhostingtools/unbound.svg)](https://hub.docker.com/r/selfhostingtools/unbound)

## What is this software

[Unbound](https://www.nlnetlabs.nl/projects/unbound/about/) is a validating, recursive, caching DNS resolver released under the BSD licence. It is designed to be fast and lean and incorporates modern features based on open standards like DNS-over-TLS.

### Features

- Lightweight & secure image (based on Alpine & multi-stage build: 11MB, no root process)
- Latest unbound version with hardening compilation options

### Run with Docker-compose

```yaml
version: '3.7'

services:
  unbound:
    container_name: unbound
    restart: always
    image: selfhostingtools/unbound:latest
    read_only: true
    volumes:
      - /mnt/unbound/conf:/etc/unbound
    ports:
      - 53:53
      - 53:53/udp
```

#### Configuration example

Put your dns zone file in `/mnt/unbound/conf/unbound.conf`

:warning: This example allows requests from any IP! (i.e. open resolver)

```yaml
server:
  use-syslog: no
  do-daemonize: no
  username: "unbound"
  directory: "/etc/unbound"
  trust-anchor-file: root.key
  interface: 0.0.0.0
  access-control: 0.0.0.0/0 allow

remote-control:
  control-enable: yes
  control-interface: 127.0.0.1
```

`control-enable: yes` is needed for Docker healthcheck.

#### Environment variables

You may want to change the running user:

| Variable | Description      | Type       | Default value |
| -------- | -----------      | ----       | ------------- |
| **UID**  | unbound user id  | *optional* | 991           |

## Build the image

Build-time variables:

- **UNBOUND_VERSION** : version of Unbound
- **GPG_FINGERPRINT** : fingerprint of signing key
- **SHA256_HASH** : SHA256 hash of Unbound archive
