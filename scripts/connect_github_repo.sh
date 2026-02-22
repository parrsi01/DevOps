#!/usr/bin/env bash
set -euo pipefail

OWNER="${1:-}"
REPO="${2:-DevOps}"

if [ -z "$OWNER" ]; then
  echo "Usage: $0 <github-username-or-org> [repo-name]"
  exit 1
fi

if [ ! -d .git ]; then
  echo "Not a git repository. Run ./scripts/bootstrap_git_repo.sh first."
  exit 1
fi

if ! gh auth status >/dev/null 2>&1; then
  echo "GitHub CLI is not authenticated. Run: gh auth login"
  exit 1
fi

REMOTE_URL="git@github.com:${OWNER}/${REPO}.git"
if git remote get-url origin >/dev/null 2>&1; then
  git remote set-url origin "$REMOTE_URL"
else
  git remote add origin "$REMOTE_URL"
fi

echo "origin -> $REMOTE_URL"
echo "Next steps:"
echo "  git add ."
echo "  git commit -m 'chore: initialize devops lab workspace'"
echo "  gh repo create ${OWNER}/${REPO} --private --source=. --remote=origin --push || git push -u origin main"
