# GitOps and Version Control

---

> **Field** — DevOps / Configuration Management
> **Scope** — Git fundamentals and GitOps workflow patterns from the GitOps lab

---

## Overview

GitOps treats Git as the single source of truth for
both application code and infrastructure configuration.
Changes are made through commits and pull requests,
and a reconciler automatically applies them to the
live system. This section covers both foundational
Git concepts and the GitOps operational model.

---

## Definitions

### `Git`

**Definition.**
A distributed version control system that tracks
changes to files over time. Every developer has a
full copy of the project history. Changes are
recorded as commits.

**Context.**
Git is the foundation for collaboration, auditability,
and rollback in DevOps. Every configuration change,
code fix, and infrastructure update should be tracked
in Git.

**Example.**
```bash
git status
# shows modified, staged, and untracked files

git log --oneline -10
# shows last 10 commits
```

---

### `Commit`

**Definition.**
A snapshot of changes saved to the Git history.
Each commit has a unique hash (SHA), an author,
a timestamp, and a message describing what changed.

**Context.**
Commits are the audit trail. Good commit messages
explain why a change was made, not just what changed.
This is critical for incident investigations.

**Example.**
```bash
git add deployment.yaml
git commit -m "Fix: increase memory limit to prevent OOM"
```

---

### `Branch`

**Definition.**
A parallel line of development. Branches let you
work on features or fixes without affecting the
main codebase until the work is ready.

**Context.**
The main branch represents the current production
state. Feature branches are merged back after
review and testing.

**Example.**
```bash
git checkout -b fix/memory-limit
# creates and switches to a new branch

git checkout main
# switches back to main branch
```

---

### `Merge`

**Definition.**
Combining changes from one branch into another.
A merge takes the commits from a feature branch
and applies them to the target branch.

**Context.**
Merge conflicts happen when two branches modify
the same lines. Resolving conflicts is a normal
part of team collaboration.

**Example.**
```bash
git checkout main
git merge fix/memory-limit
# applies feature branch changes to main
```

---

### `Pull Request`

**Definition.**
A request to merge changes from one branch into
another, with a review process. Pull requests
show the diff, allow comments, and can require
approvals before merging.

**Context.**
Pull requests enforce code review, which catches
errors, shares knowledge, and creates an audit
trail of why changes were approved.

**Example.**
```bash
gh pr create --title "Fix memory limit" \
  --body "Increases pod memory to prevent OOM kills"
```

---

### `GitOps`

**Definition.**
An operational model where the desired state of
systems and applications is stored in Git. A
reconciler watches the Git repository and
automatically applies changes to the live system.

**Context.**
GitOps changes how you fix things. Instead of
SSH-ing into a server and making manual changes,
you commit the fix to Git and let the reconciler
apply it. Manual changes get overwritten.

**Example.**
1. Developer changes `replicas: 3` in Git
2. Reconciler detects the change
3. Reconciler updates the cluster to 3 replicas
4. Cluster state now matches Git

---

### `Reconciler`

**Definition.**
A tool that continuously compares the desired state
(in Git) with the actual state (in the cluster) and
makes corrections to eliminate differences. ArgoCD
and Flux are common reconcilers.

**Context.**
The reconciler is the enforcement mechanism of GitOps.
It detects drift and corrects it automatically. If
you make a manual cluster change, the reconciler
will revert it to match Git.

**Example.**
```bash
# ArgoCD: check app sync status
argocd app get my-app
# Status: Synced / OutOfSync
```

---

### `Sync`

**Definition.**
The process of applying the desired state from Git
to the live cluster. A successful sync means the
cluster matches what is in the Git repository.

**Context.**
Sync can be automatic (reconciler watches for changes)
or manual (operator triggers it). Sync status tells
you whether the cluster is up to date with Git.

**Example.**
```bash
argocd app sync my-app
# triggers a manual sync
```

---

### `Drift (GitOps)`

**Definition.**
When the live system state differs from what is
defined in Git. Someone manually changed something
in the cluster, or a sync failed partway through.

**Context.**
In GitOps, drift is always a problem because the
reconciler will eventually try to correct it. If
you need a change to persist, commit it to Git.
Manual fixes without Git commits are temporary.

**Example.**
You run `kubectl edit deployment my-app` to change
replicas. ArgoCD detects the change as drift and
shows the app as "OutOfSync."

---

### `Rollback`

**Definition.**
Reverting to a previous known-good state. In GitOps,
rollback means reverting the Git commit and letting
the reconciler apply the old configuration.

**Context.**
GitOps makes rollback simple and auditable. You
revert a Git commit, and the reconciler handles
the rest. No manual cluster surgery required.

**Example.**
```bash
git revert HEAD
git push origin main
# reconciler detects the revert and applies
# the previous configuration
```

---

### `ArgoCD`

**Definition.**
A GitOps continuous delivery tool for Kubernetes.
ArgoCD watches Git repositories and automatically
syncs Kubernetes resources to match the desired
state defined in Git.

**Context.**
ArgoCD is the reconciler used in this course's
GitOps lab. It provides a web UI showing sync
status, health, and diff between desired and
live state.

**Example.**
```bash
# Install ArgoCD in the cluster
./scripts/install_argocd_minikube.sh

# Bootstrap applications
./scripts/bootstrap_argocd_apps.sh

# Check status
argocd app list
```

---

## Key Commands Summary

```bash
# Git basics
git status
git add <file>
git commit -m "message"
git log --oneline -10
git diff

# Branching
git checkout -b <branch>
git checkout main
git merge <branch>

# GitOps (ArgoCD)
argocd app list
argocd app get <app-name>
argocd app sync <app-name>
argocd app diff <app-name>
```

---

## See Also

- [CI/CD and DevSecOps](./07_cicd_and_devsecops.md)
- [Kubernetes](./05_kubernetes.md)
- [Deployment Strategies](./09_deployment_strategies.md)

---

> **Author** — Simon Parris | DevOps Reference Library
