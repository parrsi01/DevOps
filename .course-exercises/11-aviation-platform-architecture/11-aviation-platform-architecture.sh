#!/usr/bin/env bash
set -euo pipefail


# Block 1 from 11-aviation-platform-architecture
cd /home/sp/cyber-course/projects/DevOps
sed -n '1,120p' docs/aviation-platform-architecture.md
rg -n '^## ' docs/aviation-platform-architecture.md


# Block 2 from 11-aviation-platform-architecture
sed -n '35,140p' docs/aviation-platform-architecture.md


# Block 3 from 11-aviation-platform-architecture
sed -n '255,370p' docs/aviation-platform-architecture.md


# Block 4 from 11-aviation-platform-architecture
sed -n '370,520p' docs/aviation-platform-architecture.md


# Block 5 from 11-aviation-platform-architecture
cat > /tmp/section11-architecture-review.md <<'NOTE'
# Section 11 Architecture Review
Request path summary:
Deployment path summary:
Top 3 failure domains:
Top 3 security controls:
First scaling bottleneck I expect:
First runbooks to write:
NOTE
cat /tmp/section11-architecture-review.md
rm -f /tmp/section11-architecture-review.md

