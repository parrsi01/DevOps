# CI/CD and DevSecOps

---

> **Field** — DevOps / Continuous Integration and Delivery
> **Scope** — Pipeline concepts, GitHub Actions, and security controls from the CI/CD and DevSecOps labs

---

## Overview

CI/CD automates the process of building, testing, and
delivering software. DevSecOps adds security checks
into that pipeline so vulnerabilities are caught before
deployment. This section covers pipeline structure,
GitHub Actions, and every security control discussed
in the course.

---

## Definitions

### `CI (Continuous Integration)`

**Definition.**
The practice of automatically building and testing
code every time a developer pushes changes. CI
catches bugs early by running checks on every commit.

**Context.**
Without CI, bugs accumulate and are discovered late.
CI pipelines run linting, unit tests, and build
steps automatically.

**Example.**
A developer pushes a commit. GitHub Actions runs
lint, tests, and build within minutes. The developer
gets immediate feedback.

---

### `CD (Continuous Delivery)`

**Definition.**
The practice of automatically preparing code for
release after CI passes. CD extends CI by packaging
artifacts, publishing images, and optionally deploying
to staging or production.

**Context.**
CD does not always mean automatic deployment to
production. It means the code is always in a
deployable state.

**Example.**
After tests pass, the pipeline builds a Docker image,
pushes it to a registry, and updates a staging
environment.

---

### `Pipeline`

**Definition.**
A defined sequence of automated steps that code
goes through from commit to deployment. Pipelines
are the backbone of CI/CD.

**Context.**
Pipelines are production systems. A broken pipeline
blocks all releases and can hide quality or security
regressions.

**Example.**
A typical pipeline: lint → test → build → scan →
publish → deploy.

---

### `Workflow`

**Definition.**
A GitHub Actions pipeline definition file written
in YAML. Workflows define triggers (when to run),
jobs (what to do), and steps (individual commands).

**Context.**
Workflow files live in `.github/workflows/` and are
version-controlled alongside the code they protect.

**Example.**
```yaml
name: CI
on: [push, pull_request]
jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - run: npm test
```

---

### `Job`

**Definition.**
A set of steps that run in one execution environment
within a workflow. Jobs can run in parallel or depend
on other jobs.

**Context.**
Each job gets a fresh environment. If a job fails,
you diagnose by identifying which step within that
job failed first.

**Example.**
```yaml
jobs:
  lint:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - run: npm run lint
  test:
    needs: lint
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - run: npm test
```

---

### `Step`

**Definition.**
One command or action inside a job. Steps run
sequentially within their job. Each step either
runs a shell command or uses a pre-built action.

**Context.**
When a pipeline fails, the step that failed tells
you exactly where the problem is: code error, config
error, permission error, or environment error.

**Example.**
```yaml
steps:
  - name: Checkout code
    uses: actions/checkout@v4
  - name: Run tests
    run: npm test
```

---

### `Artifact`

**Definition.**
A file or output produced by a pipeline job and
stored for later use. Artifacts can be downloaded,
passed between jobs, or archived for auditing.

**Context.**
Common artifacts include test reports, built Docker
images, coverage reports, and scan results.

**Example.**
```yaml
- name: Upload test results
  uses: actions/upload-artifact@v4
  with:
    name: test-results
    path: test-results/
```

---

### `Secret (CI)`

**Definition.**
A sensitive value (password, token, API key) stored
securely in the CI platform and injected into
pipeline runs as environment variables.

**Context.**
Secrets must never appear in code, logs, or commit
history. CI platforms mask secret values in output.

**Example.**
```yaml
- name: Push to registry
  env:
    REGISTRY_TOKEN: ${{ secrets.REGISTRY_TOKEN }}
  run: docker push my-app:latest
```

---

### `SAST`

**Definition.**
Static Application Security Testing. Analyzing
source code for security vulnerabilities without
running the application. SAST finds issues like
SQL injection, XSS, and insecure patterns.

**Context.**
SAST runs early in the pipeline (shift-left) so
security issues are caught before deployment.
It can produce false positives that need triage.

**Example.**
CodeQL is a SAST tool used in this course:
```yaml
- name: CodeQL Analysis
  uses: github/codeql-action/analyze@v3
```

---

### `Secret Scan`

**Definition.**
Automated detection of exposed tokens, passwords,
API keys, or certificates in code files or Git
history.

**Context.**
Accidentally committed secrets are a critical
security risk. Secret scanning catches this before
the code reaches production or public repositories.

**Example.**
Gitleaks is used in this course:
```yaml
- name: Secret scan
  uses: gitleaks/gitleaks-action@v2
```

---

### `Vulnerability Scan`

**Definition.**
Checking container images or application dependencies
for known security vulnerabilities (CVEs). Scanners
compare package versions against vulnerability
databases.

**Context.**
Even if your code is secure, your dependencies may
have known vulnerabilities. Image scanning catches
these before deployment.

**Example.**
Trivy is used in this course:
```bash
trivy image my-app:latest
# scans the image for known vulnerabilities
```

---

### `Hardening`

**Definition.**
Reducing the attack surface of a system by removing
unnecessary software, tightening permissions, and
applying security best practices.

**Context.**
A hardened Docker image uses a minimal base image,
runs as non-root, and includes only the files needed
to run the application.

**Example.**
```dockerfile
FROM python:3.11-slim
# slim = smaller attack surface than full image

RUN adduser --disabled-password appuser
USER appuser
# non-root = limited blast radius if compromised
```

---

### `Policy Gate`

**Definition.**
A check in the pipeline that can block progress if
a condition is not met. Policy gates enforce minimum
security, quality, or compliance standards.

**Context.**
Policy gates prevent "ship it anyway" culture. If
the vulnerability scan finds a critical CVE, the
gate blocks deployment until it is resolved.

**Example.**
```yaml
- name: Check scan results
  run: |
    if [ "$CRITICAL_VULNS" -gt 0 ]; then
      echo "Critical vulnerabilities found"
      exit 1
    fi
```

---

### `Permission (CI)`

**Definition.**
Access rights granted to the GitHub Actions token
during pipeline execution. Permissions control what
the pipeline can read, write, create, or delete.

**Context.**
Least-privilege permissions reduce risk. A pipeline
should only have the permissions it actually needs.

**Example.**
```yaml
permissions:
  contents: read
  packages: write
  security-events: write
```

---

## Key Commands Summary

```bash
# GitHub Actions
gh workflow list
gh run list
gh run view <run-id>

# Security scanning
trivy image <image>
gitleaks detect --source .

# Pipeline workflow files
ls .github/workflows/
```

---

## See Also

- [GitOps and Version Control](./06_gitops_and_version_control.md)
- [Deployment Strategies](./09_deployment_strategies.md)
- [Containers and Docker](./02_containers_and_docker.md)

---

> **Author** — Simon Parris | DevOps Reference Library
