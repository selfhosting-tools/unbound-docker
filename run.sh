#!/bin/sh

if [ ! -f /etc/unbound/unbound_server.pem ]; then
  unbound-control-setup
fi

chown -R unbound:root /etc/unbound

# Setup or update of the root trust anchor for DNSSEC validation
unbound-anchor -a /etc/unbound/root.key

exec /sbin/tini -- unbound -d -c /etc/unbound/unbound.conf
