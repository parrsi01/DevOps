#!/usr/bin/env bash
set -euo pipefail


# Block 1 from 15-github-actions-cicd
cd /home/sp/cyber-course/projects/DevOps
sed -n '1,220p' docs/github-actions-cicd-lab.md
sed -n '1,260p' projects/github-actions-ci-demo/README.md


# Block 2 from 15-github-actions-cicd
cd /home/sp/cyber-course/projects/DevOps/projects/github-actions-ci-demo
ls .github/workflows
rg -n '^(name:|on:|permissions:|jobs:|\s{2}[a-zA-Z0-9_-]+:|\s+needs:)' .github/workflows/*.yml


# Block 3 from 15-github-actions-cicd
cat package.json
npm run lint
npm run build
ls -l dist || true


# Block 4 from 15-github-actions-cicd
sed -n '1,160p' /home/sp/cyber-course/projects/DevOps/tickets/cicd/TKT-103-docker-build-failure/README.md
cd /home/sp/cyber-course/projects/DevOps/projects/github-actions-ci-demo/examples/secure-nginx
docker build -t local-secure-nginx .


# Block 5 from 15-github-actions-cicd
cd /home/sp/cyber-course/projects/DevOps
ls -1 tickets/cicd
sed -n '1,120p' tickets/cicd/TKT-101-lint-failure/README.md
sed -n '1,120p' tickets/cicd/TKT-104-semantic-release-permission/README.md
sed -n '1,120p' tickets/cicd/TKT-105-ghcr-publish-permission/README.md

