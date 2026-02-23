# Section 15 - GitHub Actions CI/CD Lab

Source docs:

- `docs/github-actions-cicd-lab.md`
- `projects/github-actions-ci-demo/README.md`
- `tickets/cicd/`

## What Type Of Software Engineering This Is

CI/CD pipeline engineering and release operations troubleshooting.

## Definitions

- `workflow`: GitHub Actions pipeline definition file.
- `job`: grouped steps in a workflow.
- `artifact`: build output passed between jobs/stages.
- `permissions`: GitHub token scopes for workflow actions.
- `matrix`: same job run across multiple versions/environments.

## Concepts And Theme

Treat pipelines as production systems: identify the failed stage, step, and permission quickly.

## 1. Step 1 - Read the CI/CD notes and the demo project overview

```bash
cd /home/sp/cyber-course/projects/DevOps
sed -n '1,220p' docs/github-actions-cicd-lab.md
sed -n '1,260p' projects/github-actions-ci-demo/README.md
```

What you are doing: understanding the intended pipeline stages and the template project used for local inspection.

## 2. Step 2 - Inspect workflow files, job order, and permissions

```bash
cd /home/sp/cyber-course/projects/DevOps/projects/github-actions-ci-demo
ls .github/workflows
rg -n '^(name:|on:|permissions:|jobs:|\s{2}[a-zA-Z0-9_-]+:|\s+needs:)' .github/workflows/*.yml
```

What you are doing: mapping the pipeline structure and identifying where permission failures or ordering problems would occur.

## 3. Step 3 - Inspect local pipeline scripts and build targets

```bash
cat package.json
npm run lint
npm run build
ls -l dist || true
```

What you are doing: reproducing simple local pipeline stages (`lint`, `build`) so you can separate code failures from GitHub-only config failures.

## 4. Step 4 - Practice a ticket-driven troubleshooting loop (local reading + local reproduce)

```bash
sed -n '1,160p' /home/sp/cyber-course/projects/DevOps/tickets/cicd/TKT-103-docker-build-failure/README.md
cd /home/sp/cyber-course/projects/DevOps/projects/github-actions-ci-demo/examples/secure-nginx
docker build -t local-secure-nginx .
```

What you are doing: reading a CI/CD ticket and then running a related local build command to understand how to reproduce job failures outside GitHub Actions.

## 5. Step 5 - Review CI/CD ticket set in order

```bash
cd /home/sp/cyber-course/projects/DevOps
ls -1 tickets/cicd
sed -n '1,120p' tickets/cicd/TKT-101-lint-failure/README.md
sed -n '1,120p' tickets/cicd/TKT-104-semantic-release-permission/README.md
sed -n '1,120p' tickets/cicd/TKT-105-ghcr-publish-permission/README.md
```

What you are doing: practicing classification of pipeline failures (lint/code, Docker build, token permissions, package registry permissions).

## Done Check

You can classify a CI/CD failure as code, config, permissions, environment, or tooling before editing the pipeline.
