#!/usr/bin/env bash
set -euo pipefail


# Block 1 from 14-enterprise-devops-incidents
cd /home/sp/cyber-course/projects/DevOps
sed -n '1,90p' docs/enterprise-devops-incidents-lab.md
rg -n '^## [0-9]+\.' docs/enterprise-devops-incidents-lab.md


# Block 2 from 14-enterprise-devops-incidents
sed -n '42,104p' docs/enterprise-devops-incidents-lab.md


# Block 3 from 14-enterprise-devops-incidents
sed -n '506,560p' docs/enterprise-devops-incidents-lab.md


# Block 4 from 14-enterprise-devops-incidents
cat > /tmp/section14-incident-analysis.md <<'NOTE'
# Section 14 Incident Analysis
Scenario:
User impact:
Timeline:
Hypotheses (ranked):
Evidence for hypothesis #1:
Evidence against competing hypotheses:
Root cause:
Mitigation:
Permanent fix:
Preventive actions:
NOTE
cat /tmp/section14-incident-analysis.md


# Block 5 from 14-enterprise-devops-incidents
rg -n '^## (1[0-5]|[1-9])\.' docs/enterprise-devops-incidents-lab.md
rm -f /tmp/section14-incident-analysis.md

