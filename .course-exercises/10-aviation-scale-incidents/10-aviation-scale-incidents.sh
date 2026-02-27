#!/usr/bin/env bash
set -euo pipefail


# Block 1 from 10-aviation-scale-incidents
cd /home/sp/cyber-course/projects/DevOps
sed -n '1,120p' docs/aviation-scale-devops-incidents-lab.md
rg -n '^## Scenario ' docs/aviation-scale-devops-incidents-lab.md


# Block 2 from 10-aviation-scale-incidents
sed -n '39,120p' docs/aviation-scale-devops-incidents-lab.md


# Block 3 from 10-aviation-scale-incidents
sed -n '59,170p' docs/aviation-scale-devops-incidents-lab.md


# Block 4 from 10-aviation-scale-incidents
cat > /tmp/section10-incident-note.md <<'NOTE'
# Section 10 Incident Practice Note
Symptom:
User impact:
Primary failure domain:
Secondary symptoms/noise:
Evidence to collect first (commands/logs/metrics):
Likely root cause hypotheses:
Mitigation:
Permanent fix:
Prevention:
NOTE
cat /tmp/section10-incident-note.md


# Block 5 from 10-aviation-scale-incidents
sed -n '1141,1195p' docs/aviation-scale-devops-incidents-lab.md
rm -f /tmp/section10-incident-note.md

