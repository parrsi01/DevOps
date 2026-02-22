# GitOps Workflow Lab (ArgoCD + Declarative Kubernetes)

## Enterprise Program Standard

This module is part of a professional infrastructure training program (not a hobby lab).

Training expectations for this module:
- production-grade design and operational assumptions (multi-AZ/region, identity, logging, recovery)
- security controls and least-privilege decisions are part of the exercise, not optional add-ons
- audit awareness: change traceability, approvals, evidence, and rollback records should be captured
- failure domain analysis must be included (process, host/node, AZ/region, dependency, control plane)
- examples are learning-safe but mapped to enterprise patterns; avoid localhost-only reasoning during analysis
- exercises are repeatable without AI by following the documented commands, checklists, and runbooks

Senior Platform Engineer lab for building a production-style GitOps workflow locally.

This lab uses `ArgoCD` as the GitOps controller and also explains a structured GitOps workflow in a tool-agnostic way.

## What This Lab Covers

- ArgoCD-based GitOps workflow (with no-tool-dependency explanation)
- Declarative deployment model
- Git as source of truth
- Rollback strategy
- Version pinning
- Immutable image tags (recommended pattern: image digests)
- Simulations:
  - bad deployment rollback
  - config drift
  - manual production change
  - version mismatch between environments
- Troubleshooting guide

## Prerequisites

Recommended local platform:

- `Minikube` or `K3s` (use module 8: `projects/kubernetes-local-lab/`)
- `kubectl`
- optional: `argocd` CLI

This VM did not have `kubectl` / `minikube` / `argocd` installed at build time, so this lab was scaffolded and reviewed but not executed here.

## Full GitOps Explanation (Practical)

GitOps is an operational model where:

1. Desired system state is declared in Git (YAML, Helm, Kustomize, etc.)
2. A controller (ArgoCD/Flux) continuously compares cluster state vs Git state
3. Differences are reconciled back toward Git (optionally self-heal)
4. Changes happen through commits/PRs, not manual cluster edits

### Key Principles

- **Declarative model**: define *what should exist*, not imperative step sequences
- **Git as source of truth**: production intent lives in versioned, reviewable commits
- **Pull-based reconciliation**: cluster agent pulls from Git (safer than CI pushing directly)
- **Auditability**: every deployment maps to a commit/PR
- **Reproducibility**: environments can be rebuilt from Git manifests

## Tool-agnostic GitOps Workflow (No ArgoCD dependency)

Even without ArgoCD, a structured GitOps flow still looks like this:

1. App CI builds image
2. CI publishes immutable artifact (digest)
3. CI opens PR updating environment manifest (e.g., prod image digest)
4. Review/approval merges PR
5. A deploy agent (or controlled pipeline) applies the declarative manifests
6. Drift detection compares live vs Git periodically

ArgoCD automates steps 5 and 6 continuously and makes drift visible.

## Declarative Deployment Model (This Lab)

This repo models one application (`podinfo`) using Kustomize:

- `apps/base/podinfo/` -> shared base resources (Deployment, Service, Ingress, ConfigMap)
- `apps/overlays/dev/` -> dev-specific patches
- `apps/overlays/staging/` -> staging-specific patches
- `apps/overlays/prod/` -> prod-specific patches

Benefits:

- shared defaults in base
- environment-specific overrides are small and reviewable
- promotion is a manifest change (usually image version + replicas/config)

## Git As Source of Truth (What Changes Are Allowed)

### Allowed (GitOps-safe)

- change image version in overlay (`patch-deployment.yaml`)
- change replicas, config, ingress host via PR
- revert bad changes with `git revert`

### Not allowed (anti-pattern)

- `kubectl edit` in production as a permanent fix
- manual scaling/image changes without PR
- using mutable tags like `latest` in production manifests

If ArgoCD `selfHeal: true` is enabled, manual changes are automatically reverted to match Git.

## Version Pinning and Immutable Image Tags

## Version pinning (required)

Pin versions explicitly in manifests (or generated overlays):

- image versions
- Helm chart versions (if using Helm)
- Kustomize remote bases (if any)

Why:

- reproducible rollbacks
- predictable promotion across environments
- fewer surprise upgrades

## Immutable image tags (best practice)

Production standard: **deploy by digest**, not mutable tags.

Recommended format:

```yaml
image: ghcr.io/your-org/app@sha256:<digest>
```

This lab uses a real tag (`:6.7.1`) for local runnability, but your production workflow should update overlays to image digests produced by CI.

### Promotion pattern (good)

- CI builds image and publishes digest
- CI writes/PRs digest to `dev`
- after validation, promote **the same digest** to `staging`
- then promote **the same digest** to `prod`

## Rollback Strategy (GitOps-native)

Primary rollback method: **Git revert**.

1. Identify bad commit/PR that changed deployment manifests
2. `git revert <commit>` (or revert the PR in GitHub)
3. Push revert commit
4. ArgoCD reconciles cluster back to previous declared state

Why this is preferred:

- rollback is auditable
- cluster state remains aligned with Git
- avoids hidden hotfix drift

Emergency option:

- Manual sync to a previous Git revision in ArgoCD UI/CLI (still tied to Git history)
- Then follow up with a normal Git revert/PR to keep repo and cluster aligned

## Deployment Diagram (GitOps with ArgoCD)

```text
Developer -> Pull Request -> GitHub Repo (DevOps)
                 |                |
                 | merge          | source of truth (manifests/overlays)
                 v                v
           CI builds image   ArgoCD watches repo
           publishes artifact       |
           (prefer digest)          | detects desired state changes / drift
                 |                  v
                 |          ArgoCD Application sync
                 |                  |
                 +---- PR updates environment overlay image/config ----+
                                    |
                                    v
                           Kubernetes cluster (dev/staging/prod namespaces)
                                    |
                                    v
                             Running pods/services/ingress
```

## ArgoCD Setup (Local Cluster)

If using module 8 (`kubernetes-local-lab`), ensure cluster + ingress are running first.

### Install ArgoCD (Minikube path)

```bash
cd projects/gitops-workflow-lab
./scripts/install_argocd_minikube.sh
```

### Access ArgoCD UI

```bash
kubectl -n argocd port-forward svc/argocd-server 8080:443
```

Open: `https://127.0.0.1:8080`

Get initial admin password:

```bash
kubectl -n argocd get secret argocd-initial-admin-secret \
  -o jsonpath='{.data.password}' | base64 -d; echo
```

Optional CLI login:

```bash
argocd login 127.0.0.1:8080 --username admin --password <password> --insecure
```

### Bootstrap GitOps Applications

```bash
./scripts/bootstrap_argocd_apps.sh
kubectl -n argocd get applications.argoproj.io
```

ArgoCD resources in this lab:

- `argocd/project.yaml` -> AppProject scoping source repo and destinations
- `argocd/root-app.yaml` -> optional app-of-apps style root Application
- `argocd/applications/*.yaml` -> `dev`, `staging`, `prod` Applications

## Render and Review Manifests Before Sync (Important Habit)

```bash
./scripts/render_overlay.sh dev
./scripts/render_overlay.sh staging
./scripts/render_overlay.sh prod
```

Review differences across environments:

```bash
./scripts/show_version_matrix.sh
```

## Simulations (GitOps Incidents)

These focus on cross-layer reasoning: Git history, ArgoCD sync state, cluster resources, and runtime impact.

## 1. Bad Deployment Rollback

### Goal
Simulate a bad production manifest change and roll back the GitOps-native way.

### Simulate (example)

1. Edit `apps/overlays/prod/patch-deployment.yaml`
2. Change image to a bad tag (e.g., `:not-a-real-tag`) or bad config patch
3. Commit + push + merge
4. ArgoCD syncs -> prod becomes degraded (`ImagePullBackOff` or app failure)

Example local commands:

```bash
git checkout -b break/prod-bad-image
# edit prod patch-deployment.yaml -> invalid image
git commit -am "feat: promote podinfo bad image to prod"
git push -u origin break/prod-bad-image
```

### What to observe

- ArgoCD app status: `Degraded` / `OutOfSync` / sync error depending on failure
- Kubernetes deployment/pods in `platform-prod`
- `kubectl describe pod` events (e.g., image pull failures)

### Rollback (step by step)

```bash
git revert <bad-commit-sha>
git push
```

Then verify:

```bash
kubectl -n argocd get applications.argoproj.io podinfo-prod
kubectl -n platform-prod rollout status deploy/podinfo
kubectl -n platform-prod get pods
```

### Root cause
Git commit introduced bad desired state; ArgoCD correctly applied it because Git is source of truth.

### Key lesson
GitOps does not prevent bad config. It makes bad changes visible, auditable, and reversible.

## 2. Config Drift

### Goal
Show ArgoCD drift detection and self-healing.

### Simulate (manual scale drift)

```bash
kubectl -n platform-prod scale deploy/podinfo --replicas=7
```

### Observe

```bash
kubectl -n platform-prod get deploy podinfo
kubectl -n argocd get applications.argoproj.io podinfo-prod
# if argocd CLI is installed:
argocd app get podinfo-prod
```

Expected with `selfHeal: true`:

- ArgoCD marks app `OutOfSync`
- ArgoCD syncs and resets replicas to Git-declared value (`3`)

### Root cause
Live cluster spec was changed out-of-band and no longer matched Git desired state.

### Fix
No Git change needed if manual change was accidental. ArgoCD self-heal (or manual sync) restores Git state.

## 3. Manual Production Change (Anti-pattern)

### Goal
Demonstrate why `kubectl set image` in prod breaks GitOps discipline.

### Simulate

```bash
kubectl -n platform-prod set image deploy/podinfo podinfo=ghcr.io/stefanprodan/podinfo:latest
```

### Observe

- Cluster changes immediately
- Git overlay still declares pinned version
- ArgoCD detects drift and reverts (if self-heal enabled)

### Debug commands

```bash
kubectl -n platform-prod get deploy podinfo -o jsonpath='{.spec.template.spec.containers[0].image}'; echo
kubectl -n argocd get applications.argoproj.io podinfo-prod
argocd app diff podinfo-prod   # optional CLI
```

### Root cause
Operational change bypassed Git and changed live cluster state directly.

### Fix (step by step)

1. Stop making manual changes in prod
2. Revert to Git-defined state via ArgoCD sync or wait for self-heal
3. If change was actually needed, submit PR updating prod overlay

## 4. Version Mismatch Between Environments

### Goal
Show how unstructured promotions cause environment inconsistency.

### Simulate

- Update `dev` to a newer version
- Leave `staging` unchanged
- Accidentally set `prod` to a different version than tested in `staging`

Check matrix:

```bash
./scripts/show_version_matrix.sh
```

### What to reason through

- Did prod get the same artifact validated in staging?
- Is the version pinned or mutable?
- Is the mismatch intentional (progressive rollout) or accidental?

### Root cause
Promotion process copied the wrong version into prod overlay (human error or CI pipeline bug).

### Fix (step by step)

1. Identify the approved staging version (prefer digest)
2. Update `apps/overlays/prod/patch-deployment.yaml` to the exact approved artifact
3. Merge PR and verify ArgoCD sync
4. Add CI policy checks for promotion consistency

## Troubleshooting Guide (GitOps + ArgoCD)

Use this when apps are `OutOfSync`, `Degraded`, or not updating as expected.

## 1. Is Git correct?

Check:

- recent commits / PRs
- correct branch (`main` for prod in this lab)
- manifest syntax and overlay path
- image tag/digest correctness

Commands:

```bash
git log --oneline --decorate -20
./scripts/render_overlay.sh prod
./scripts/show_version_matrix.sh
```

## 2. Is ArgoCD pointing to the right repo/path/revision?

```bash
kubectl -n argocd get applications.argoproj.io
kubectl -n argocd get application podinfo-prod -o yaml | rg -n 'repoURL|targetRevision|path|destination'
# optional CLI
argocd app get podinfo-prod
```

Common issues:

- wrong `path`
- wrong `targetRevision`
- repo auth failure
- namespace mismatch

## 3. Is ArgoCD failing to sync?

Check controller/application events and status:

```bash
kubectl -n argocd describe application podinfo-prod
kubectl -n argocd logs deploy/argocd-application-controller --tail=200 | rg -i 'podinfo-prod|error|denied|sync'
```

Common issues:

- RBAC denies resource creation
- invalid manifests
- missing CRDs (for custom resources)
- destination namespace or ingress class assumptions mismatch

## 4. Did Kubernetes accept the manifests but workload still fail?

```bash
kubectl -n platform-prod get deploy,rs,pods,svc,ingress
kubectl -n platform-prod describe deploy podinfo
kubectl -n platform-prod describe pod -l app=podinfo
kubectl -n platform-prod logs deploy/podinfo --tail=100
kubectl -n platform-prod get events --sort-by=.lastTimestamp | tail -n 30
```

This is often a runtime issue, not a GitOps issue (image broken, probes failing, service selector mismatch, etc.).

## 5. Drift / self-heal behavior unclear?

```bash
kubectl -n argocd get application podinfo-prod -o yaml | rg -n 'selfHeal|prune'
kubectl -n platform-prod scale deploy/podinfo --replicas=7
kubectl -n argocd get applications.argoproj.io podinfo-prod -w
```

If self-heal is disabled:

- app stays `OutOfSync` until manual sync

## 6. Rollback is taking too long or failing

Check:

- revert commit merged to tracked branch?
- ArgoCD sync policy enabled?
- cluster resources blocked by PDB/probes/image pull?

Commands:

```bash
git log --oneline --decorate -10
kubectl -n argocd get applications.argoproj.io podinfo-prod
kubectl -n platform-prod rollout status deploy/podinfo --timeout=180s
kubectl -n platform-prod rollout history deploy/podinfo
```

## GitOps Troubleshooting Cheatsheet

### Git / Manifest Review

```bash
git status
git log --oneline -20
./scripts/render_overlay.sh dev
./scripts/render_overlay.sh staging
./scripts/render_overlay.sh prod
./scripts/show_version_matrix.sh
```

### ArgoCD (kubectl)

```bash
kubectl -n argocd get applications.argoproj.io
kubectl -n argocd describe application podinfo-prod
kubectl -n argocd logs deploy/argocd-application-controller --tail=200
kubectl -n argocd logs deploy/argocd-repo-server --tail=200
```

### ArgoCD (CLI optional)

```bash
argocd app list
argocd app get podinfo-prod
argocd app diff podinfo-prod
argocd app sync podinfo-prod
argocd app rollback podinfo-prod <id>
```

### Kubernetes Runtime Checks

```bash
kubectl -n platform-prod get deploy,rs,pods,svc,ingress
kubectl -n platform-prod describe pod -l app=podinfo
kubectl -n platform-prod logs deploy/podinfo --tail=100
kubectl -n platform-prod get events --sort-by=.lastTimestamp | tail -n 30
```

## Notes on Security and Production Hardening (Next Step)

For a real production GitOps setup, add:

- repo branch protections + CODEOWNERS
- signed commits/tags (optional but useful)
- image signature verification / provenance checks
- policy checks (OPA/Gatekeeper/Kyverno)
- secret management (External Secrets / SOPS / Vault), not plain Kubernetes Secrets in Git
- environment-specific ArgoCD projects/RBAC
