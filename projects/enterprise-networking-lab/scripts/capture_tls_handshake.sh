#!/usr/bin/env bash
# Author: Simon Parris
# Date: 2026-02-22
set -euo pipefail

host="${1:-api.company.aero}"
port="${2:-443}"
iface="${3:-eth0}"
out="${4:-tls-${host//./-}.pcap}"

cat <<MSG
TLS capture recipe (enterprise-safe wrapper)
- Host: $host
- Port: $port
- Interface: $iface
- Output: $out
MSG

echo "1) Run packet capture (requires sudo):"
echo "   sudo tcpdump -ni $iface -s 0 -vvv -w $out 'host $host and tcp port $port'"
echo "2) In another terminal, test handshake:"
echo "   openssl s_client -connect $host:$port -servername $host -showcerts"
echo "3) Optional HTTP test:"
echo "   curl -vk https://$host/health"
