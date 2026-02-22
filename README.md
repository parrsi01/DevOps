# DevOps Mastery Lab Workspace

Repeatable hands-on DevOps labs for Linux, Docker, and GitHub Actions CI/CD.

## Start Here

1. Open this repo in VS Code.
2. Run `Lab: Setup Workspace` from VS Code tasks.
3. Open `tickets/README.md` and pick one ticket demo.
4. Practice the incident, fix it, and commit your notes.

## Quick Links (Mobile-Friendly)

- `docs/README.md` - notes + study runbooks index
- `projects/README.md` - live labs you run locally
- `tickets/README.md` - repeatable incident drills
- `scripts/` - setup / git / VS Code helper scripts
- `.vscode/tasks.json` - one-click tasks in VS Code
- `.devcontainer/devcontainer.json` - portable dev environment

## Repo Layout

- `docs/`
  - Linux, Docker, and CI/CD notes
  - Git/GitHub setup notes
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
