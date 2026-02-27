#!/usr/bin/env bash
set -euo pipefail


# Block 1 from 16-ticket-demo-library
cd /home/sp/cyber-course/projects/DevOps
sed -n '1,220p' docs/ticket-demo-index.md
sed -n '1,220p' tickets/README.md


# Block 2 from 16-ticket-demo-library
ls -1 tickets/docker
ls -1 tickets/cicd
sed -n '1,220p' tickets/docker/TKT-001-crash-loop/README.md


# Block 3 from 16-ticket-demo-library
cd /home/sp/cyber-course/projects/DevOps/projects/docker-production-lab
docker build -t docker-prod-lab:prod .
./scripts/simulate_crash_loop.sh
docker ps -a --filter name=crash-loop
docker inspect -f 'status={{.State.Status}} exit={{.State.ExitCode}} restarts={{.RestartCount}}' crash-loop
docker logs crash-loop --tail 50


# Block 4 from 16-ticket-demo-library
docker rm -f crash-loop
cd /home/sp/cyber-course/projects/DevOps
sed -n '1,160p' tickets/cicd/TKT-101-lint-failure/README.md


# Block 5 from 16-ticket-demo-library
cat > /tmp/section16-ticket-note.md <<'NOTE'
# Ticket Practice Note
Ticket ID:
Reproduction proof:
Debug evidence (commands + key output):
Root cause:
Fix:
Verification:
Reset confirmation:
NOTE
cat /tmp/section16-ticket-note.md
rm -f /tmp/section16-ticket-note.md

