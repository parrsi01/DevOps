#!/usr/bin/env bash
set -euo pipefail


# Block 1 from 13-enterprise-audit-refactor
cd /home/sp/cyber-course/projects/DevOps
sed -n '1,120p' docs/enterprise-infrastructure-audit-refactor-program.md


# Block 2 from 13-enterprise-audit-refactor
sed -n '102,236p' docs/enterprise-infrastructure-audit-refactor-program.md


# Block 3 from 13-enterprise-audit-refactor
sed -n '263,381p' docs/enterprise-infrastructure-audit-refactor-program.md


# Block 4 from 13-enterprise-audit-refactor
cat > /tmp/section13-audit-checklist.md <<'NOTE'
# Section 13 Audit Checklist
Module reviewed:
Logging standard present:
Version pinning present:
Secrets isolation present:
Rollback procedure documented:
DR considerations documented:
Evidence capture workflow documented:
Highest-risk gap:
First remediation step:
NOTE
cat /tmp/section13-audit-checklist.md


# Block 5 from 13-enterprise-audit-refactor
sed -n '640,760p' docs/enterprise-infrastructure-audit-refactor-program.md
rm -f /tmp/section13-audit-checklist.md

