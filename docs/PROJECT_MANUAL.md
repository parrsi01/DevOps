# PROJECT_MANUAL

Operating manual for the `DevOps` learning repository.

## Purpose

This repository is a repeatable DevOps lab environment focused on practical operations and production-style troubleshooting.

Goals:

- learn by running real commands and services
- practice failure debugging with ticket-style scenarios
- keep notes and fixes versioned in Git
- maintain a mobile-readable documentation structure on GitHub

## Repository Modules

1. Linux mastery (notes + command drills)
2. Docker production lab (live container project + failures)
3. GitHub Actions CI/CD templates and failure simulations
4. Monitoring stack lab (Prometheus/Grafana/Loki)
5. Ticket demo library (Docker + CI/CD incidents)

## Standard Practice Loop (Recommended)

1. Pick a module or ticket.
2. Read the corresponding `README.md` / docs note.
3. Run the baseline project (or reproduce the issue).
4. Capture evidence (commands, logs, metrics, screenshots if useful).
5. Apply the fix.
6. Write/update notes.
7. Commit and push.

## VS Code Workflow

- Open repo: `code /home/sp/cyber-course/projects/DevOps`
- Install extensions: `./scripts/install_vscode_extensions.sh`
- Use tasks from `.vscode/tasks.json`
- Optional: use `.devcontainer/` for a portable environment

## Git Workflow

Daily use:

```bash
git status
git add .
git commit -m "docs: update notes"   # or feat/fix/chore
git push
```

If push/auth fails, see `git-github-setup.md`.

## Documentation Quality Standard

To stay aligned with your other learning repositories (including `datascience`):

- every major folder should have a short index `README.md`
- root README should include quick links + module map + quick start
- docs must be offline-readable and step-oriented
- simulations must include reproduce/debug/fix/reset steps where applicable
- write for GitHub mobile readability (short sections, minimal clutter)

## Safety Notes

- Use a disposable VM/snapshot for firewall/disk/system experiments
- Docker labs intentionally simulate failures; clean up containers/volumes after practice
- Do not commit secrets, tokens, or personal credentials
