#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."

cat <<'MSG'
Simulate bad deployment rollback (GitOps)

1. Introduce a bad prod change in Git (example: bad image digest or bad config patch)
2. Commit and push
3. ArgoCD syncs the bad state to prod (desired state from Git)
4. Detect failure in app/ArgoCD status
5. Roll back with Git revert (preferred) or revert commit in PR flow
6. Push revert commit
7. ArgoCD reconciles prod back to last good state

Example commands:
  git checkout -b break/prod-image
  # edit apps/overlays/prod/patch-deployment.yaml to invalid digest
  git commit -am "feat: deploy prod image digest <bad>"
  git push -u origin break/prod-image
  # merge (simulation)
  git revert <bad-commit-sha>
  git push
MSG
