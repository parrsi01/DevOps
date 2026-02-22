#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."

cat <<'MSG'
Simulate version mismatch between environments

Example mismatch:
- dev overlay image digest promoted to new version
- staging remains old digest
- prod accidentally points to a different digest than approved staging

Use:
  ./scripts/show_version_matrix.sh

What to check:
- Is prod digest equal to an approved staging digest?
- Is promotion sequence documented (dev -> staging -> prod)?
- Are images immutable digests, not mutable tags?

Fix strategy:
1. Promote by PR copying the exact digest from staging to prod.
2. Require review/approval on prod overlay changes.
3. Add CI policy that blocks prod digest not seen in staging history.
MSG
