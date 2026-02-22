#!/usr/bin/env bash
# Author: Simon Parris
# Date: 2026-02-22
set -euo pipefail

host="${1:-api.company.aero}"
iface="${2:-eth0}"

cat <<MSG
DNS capture + trace recipe
- Host: $host
- Interface: $iface
MSG

echo "1) Packet capture (requires sudo):"
echo "   sudo tcpdump -ni $iface -s 0 -vvv 'udp port 53 or tcp port 53'"
echo "2) Resolver path checks:"
echo "   dig $host"
echo "   dig +trace $host"
echo "   resolvectl query $host 2>/dev/null || true"
echo "3) If Kubernetes node:"
echo "   kubectl -n kube-system logs deploy/coredns --tail=100"
