#!/usr/bin/env bash
set -euo pipefail


# Block 1 from 07-devsecops-cicd
cd /home/sp/cyber-course/projects/DevOps
sed -n '1,220p' docs/devsecops-cicd-lab.md
sed -n '1,220p' projects/github-actions-ci-demo/README.md


# Block 2 from 07-devsecops-cicd
cd /home/sp/cyber-course/projects/DevOps/projects/github-actions-ci-demo
ls .github/workflows
rg -n 'trivy|gitleaks|codeql|audit|dependency-review|permissions:' .github/workflows/*.yml


# Block 3 from 07-devsecops-cicd
ls examples/secure-nginx
sed -n '1,220p' examples/secure-nginx/Dockerfile
sed -n '1,220p' examples/secure-nginx/Dockerfile.insecure


# Block 4 from 07-devsecops-cicd
echo 'AWS_SECRET_ACCESS_KEY=AKIAEXAMPLESECRET1234567890' > tmp-secret-demo.env
rg -n 'AWS_SECRET_ACCESS_KEY' tmp-secret-demo.env


# Block 5 from 07-devsecops-cicd
npm ci
npm audit --audit-level=high


# Block 6 from 07-devsecops-cicd
rm -f tmp-secret-demo.env
rg -n 'Trivy|gitleaks|CodeQL|CVSS|risk' README.md docs/devsecops-cicd-lab.md

