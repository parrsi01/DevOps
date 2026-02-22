# DevOps Mastery Lab Workspace

Repeatable hands-on DevOps labs for Linux, Docker, and GitHub Actions CI/CD.

Author: Simon Parris  
Date: 2026-02-22

## Start Here

1. Open this repo in VS Code.
2. Run `Lab: Setup Workspace` from VS Code tasks.
3. Open `tickets/README.md` and pick one ticket demo.
4. Practice the incident, fix it, and commit your notes.

## Quick Links (Mobile-Friendly)

- `docs/README.md` - notes + study runbooks index
- `docs/OFFLINE_INDEX.md` - offline-first documentation index
- `docs/PROJECT_MANUAL.md` - repository operating manual
- `docs/REPOSITORY_STATUS_REPORT.md` - current repo capability/status summary
- `docs/enterprise-devops-incidents-lab.md` - 15 enterprise incident drills
- `projects/README.md` - live labs you run locally
- `tickets/README.md` - repeatable incident drills
- `scripts/` - setup / git / VS Code helper scripts
- `.vscode/tasks.json` - one-click tasks in VS Code
- `.devcontainer/devcontainer.json` - portable dev environment

## Overview

This repository is a reproducible DevOps learning lab for Linux operations, Docker production troubleshooting, GitHub Actions CI/CD, and observability/monitoring.

It is structured for repeat practice: each module includes runnable examples, intentional break scenarios, and ticket-style debug workflows.

## Learning Modules

- Linux Mastery Lab
  - permissions, users/groups, process/service/log debugging, networking, firewall, cron, disk/memory/ports
- Docker Production Lab
  - Dockerfile best practices, multi-stage builds, non-root containers, volumes, networking, restart/logging, failure simulations
- GitHub Actions CI/CD Lab
  - lint/test/build, semantic version tagging, docker publish, branch protection, secret management, pipeline failure simulations
- Monitoring Stack Lab
  - Prometheus, Grafana, Loki, app/container/system metrics, dashboards, metric interpretation, SLI/SLO basics
- Enterprise Incident Simulation Lab
  - 15 realistic cross-layer DevOps incidents with logs, metrics, root cause, resolution, and preventive actions
- Ticket Demo Library
  - repeatable incident drills for Docker and CI/CD workflows

## Repo Layout

- `docs/`
  - module notes, offline indexes, operating manual, repo status
- `projects/`
  - `docker-production-lab/` live container lab + failure scripts
  - `monitoring-stack-lab/` monitoring + observability lab
  - `github-actions-ci-demo/` CI/CD workflow templates
- `tickets/`
  - Docker incident simulations
  - CI/CD pipeline failure simulations

## Quick Start

```bash
./scripts/setup_workspace.sh
./scripts/install_vscode_extensions.sh
```

Optional (portable IDE):

1. Open in VS Code
2. `Dev Containers: Reopen in Container`
3. Run lab scripts inside the container workspace

## Live Lab Commands

Docker lab:

```bash
cd projects/docker-production-lab
docker compose up -d --build
curl http://127.0.0.1:8080/health
```

Reset Docker lab:

```bash
docker compose down -v --remove-orphans
```

Monitoring lab:

```bash
cd projects/monitoring-stack-lab
./scripts/start.sh
```

Grafana: `http://127.0.0.1:3000` (`admin` / `admin`)

## Documentation Standards (Repository Quality)

This repo is maintained to match the same learning-repo quality standard as your `datascience` repository:

- root README with navigation + quick start + module map
- offline-readable docs index and manual
- repeatable run/reset instructions
- mobile-friendly Markdown structure (short sections, linkable paths, minimal wide tables)
- ticket demos with reproduce/debug/fix/reset workflow

## Reproducibility & Practice Workflow

- All major labs are runnable from local scripts or Docker Compose
- Simulations are intentional and repeatable (CPU, memory, latency, logging, CI/CD failures)
- Notes are stored in-repo for offline review and commit history tracking
- VS Code tasks and devcontainer config provide a consistent execution environment

## Daily Commit / Push Loop

```bash
git status
git add .
git commit -m "docs: update lab notes"
git push
```

## GitHub Push Checklist (If Push Fails)

```bash
git status
git remote -v
git config --get user.name
git config --get user.email
gh auth status
```

Repo bootstrap helpers (for new folders):

```bash
./scripts/bootstrap_git_repo.sh
./scripts/connect_github_repo.sh <github-username-or-org> DevOps
```
