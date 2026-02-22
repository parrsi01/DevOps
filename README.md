# DevOps Mastery Lab Workspace

Repeatable hands-on DevOps labs for Linux, Docker, and GitHub Actions CI/CD.

## What this repo includes

- `docs/` structured lab notes and runbooks
- `projects/docker-production-lab/` live Docker exercises and failure simulations
- `projects/github-actions-ci-demo/` production-grade CI/CD workflow templates
- `tickets/` repeatable incident/ticket demos you can practice anytime
- `.vscode/` VS Code extensions, tasks, and settings
- `.devcontainer/` Dev Container config for a portable IDE setup
- `scripts/` bootstrap helpers for VS Code extensions and Git/GitHub setup

## Recommended workflow (repeatable)

1. Open this folder in VS Code.
2. Install recommended extensions (`Ctrl+Shift+P` -> `Extensions: Show Recommended Extensions`).
3. Reopen in Dev Container (`Ctrl+Shift+P` -> `Dev Containers: Reopen in Container`) if desired.
4. Run ticket demos from `tickets/` and project scripts.
5. Commit your notes and fixes after each practice run.

## Quick start

```bash
./scripts/setup_workspace.sh
./scripts/install_vscode_extensions.sh
```

## GitHub push status checklist

If your changes are not pushing, check:

```bash
git status
git remote -v
git config --get user.name
git config --get user.email
gh auth status
```

Then use:

```bash
./scripts/bootstrap_git_repo.sh
./scripts/connect_github_repo.sh <github-username-or-org> DevOps
```
