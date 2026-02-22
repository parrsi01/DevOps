#!/usr/bin/env bash
set -euo pipefail

if [ ! -d .git ]; then
  git init
  git branch -M main
fi

if ! git config --get user.name >/dev/null; then
  echo "No local git user.name set. Example: git config user.name \"Your Name\""
fi
if ! git config --get user.email >/dev/null; then
  echo "No local git user.email set. Example: git config user.email \"you@example.com\""
fi

git status --short --branch
