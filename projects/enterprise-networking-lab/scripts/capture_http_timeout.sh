#!/usr/bin/env bash
# Author: Simon Parris
# Date: 2026-02-22
set -euo pipefail

host="${1:-api.company.aero}"
port="${2:-443}"
iface="${3:-eth0}"

cat <<MSG
HTTP timeout troubleshooting capture recipe
- Host: $host
- Port: $port
- Interface: $iface
MSG

echo "1) Capture packets (requires sudo):"
echo "   sudo tcpdump -ni $iface -s 0 -vvv 'host $host and tcp port $port'"
echo "2) Generate timed request:"
echo "   curl -vk --max-time 5 https://$host/health"
echo "3) Check local sockets:"
echo "   ss -tn state syn-sent,syn-recv,established '( dport = :$port or sport = :$port )'"
echo "4) Correlate with ingress/app logs and metrics timestamps"
