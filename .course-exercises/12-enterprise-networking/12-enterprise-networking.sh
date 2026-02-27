#!/usr/bin/env bash
set -euo pipefail


# Block 1 from 12-enterprise-networking
cd /home/sp/cyber-course/projects/DevOps
sed -n '1,180p' projects/enterprise-networking-lab/README.md
cd projects/enterprise-networking-lab
./scripts/preflight.sh


# Block 2 from 12-enterprise-networking
./scripts/capture_dns_path.sh api.company.aero eth0


# Block 3 from 12-enterprise-networking
./scripts/capture_tls_handshake.sh api.company.aero 443 eth0


# Block 4 from 12-enterprise-networking
./scripts/capture_http_timeout.sh api.company.aero 443 eth0
tracepath api.company.aero
ping -M do -s 1472 api.company.aero
ping -M do -s 1400 api.company.aero


# Block 5 from 12-enterprise-networking
cd /home/sp/cyber-course/projects/DevOps/projects/enterprise-networking-lab
sed -n '1,220p' templates/incident-note-template.md

