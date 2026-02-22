# GitHub Actions CI/CD Demo (Production Template + DevSecOps)

Author: Simon Parris  
Date: 2026-02-22

## Enterprise Program Standard

This module is part of a professional infrastructure training program (not a hobby lab).

Training expectations for this module:
- production-grade design and operational assumptions (multi-AZ/region, identity, logging, recovery)
- security controls and least-privilege decisions are part of the exercise, not optional add-ons
- audit awareness: change traceability, approvals, evidence, and rollback records should be captured
- failure domain analysis must be included (process, host/node, AZ/region, dependency, control plane)
- examples are learning-safe but mapped to enterprise patterns; avoid localhost-only reasoning during analysis
- exercises are repeatable without AI by following the documented commands, checklists, and runbooks

This folder contains a production-style GitHub Actions pipeline skeleton with DevSecOps controls integrated into CI/CD.

## Core CI/CD Pipeline

- `lint` -> `test` -> `build` -> `docker-build-verify`
- semantic version tagging via `semantic-release`
- Docker publish on version tags to `GHCR`

## DevSecOps Integrations Added

- Trivy container image scanning
- Trivy config scanning (Dockerfile / IaC misconfig patterns)
- Dependency vulnerability scanning (`npm audit`, dependency review, Trivy FS)
- Secrets scanning (`gitleaks`)
- SAST basic integration (`CodeQL` workflow)
- Docker image hardening example (minimal base + non-root runtime)
- Security header verification in CI (hardened Nginx example)

## Files (Security-Focused)

Workflows:

- `.github/workflows/ci.yml` - CI + secrets/dependency/container scan gates
- `.github/workflows/docker-publish.yml` - release publish with pre-push Trivy gate
- `.github/workflows/sast-codeql.yml` - basic CodeQL SAST workflow

Example scan target:

- `examples/secure-nginx/` - hardened Docker image + security headers + insecure Dockerfile for drills

## Quick Security Workflow Summary

1. Developer opens PR.
2. CI runs lint/tests/build.
3. CI runs secrets scan (`gitleaks`).
4. CI runs dependency scans (`npm audit`, dependency review, Trivy FS).
5. CI runs Dockerfile/config scan (Trivy config).
6. CI builds hardened image, verifies security headers, runs Trivy image scan.
7. If all pass, release/publish stages can continue.

## Docker Image Hardening (What Was Added)

The example hardened image (`examples/secure-nginx/Dockerfile`) demonstrates:

- minimal base image (`nginxinc/nginx-unprivileged:...-alpine`)
- non-root execution (`USER 101`)
- explicit file ownership/permissions
- health check
- no runtime package installation during container startup

The insecure counterpart (`Dockerfile.insecure`) intentionally shows bad patterns for scanner detection drills.

## Security Headers (What Is Checked in CI)

CI starts the hardened container and verifies headers using `curl -I` + `grep`:

- `X-Content-Type-Options`
- `X-Frame-Options`
- `Content-Security-Policy`

The Nginx config also includes:

- `Referrer-Policy`
- `Permissions-Policy`
- `Strict-Transport-Security`

## Simulations (Repeatable DevSecOps Drills)

## 1. Vulnerable Dependency

### Simulate

In `package.json`, intentionally add/update a known vulnerable dependency version (example only):

```json
"dependencies": {
  "lodash": "4.17.15"
}
```

Then run CI or local checks:

```bash
npm install
npm audit --audit-level=high
```

### Expected detections

- `npm audit` fails
- `actions/dependency-review-action` flags vulnerable dependency in PR
- Trivy FS scan may also flag library vulnerabilities

### Resolution

- Upgrade to patched version
- Re-run audit and CI

## 2. Hardcoded Secret Detection

### Simulate

Add a fake credential string to a temp file (do not commit real secrets):

```bash
echo 'AWS_SECRET_ACCESS_KEY=AKIAEXAMPLESECRET1234567890' > tmp-secret-demo.env
```

Run CI (or local scanner if installed).

### Expected detections

- `gitleaks` job fails on secret pattern
- Trivy FS secret scan may also flag it

### Resolution

- Remove the file/secret
- Rotate if it was a real credential (always assume exposure)
- Add ignore rules only for documented false positives

Cleanup:

```bash
rm -f tmp-secret-demo.env
```

## 3. Critical CVE in Base Image

### Simulate

Switch CI build context to `examples/secure-nginx/Dockerfile.insecure` or replace hardened base image with an old base (e.g., `ubuntu:18.04`) and run CI.

### Expected detections

- Trivy image scan returns `HIGH` / `CRITICAL` findings
- publish workflow blocks before push

### Resolution

- Update to a supported minimal base image
- rebuild and rescan
- review fixed vs unfixed CVEs and package necessity

## 4. Insecure Dockerfile Pattern

### Simulate

Use `Dockerfile.insecure` (patterns include root runtime, old base, `ADD` remote URL, broad package upgrades, unpinned install flow).

### Expected detections

- Trivy config scan flags misconfiguration/security issues
- image scan shows increased CVEs due to larger/older base

### Resolution

- move to minimal base image
- run as non-root
- avoid `ADD` remote URLs
- reduce packages and layers
- pin base versions and rebuild frequently

## CVSS Scoring (What It Means)

CVSS (Common Vulnerability Scoring System) is a standardized severity score for vulnerabilities, typically `0.0` to `10.0`.

Typical buckets:

- `Low`: `0.1 - 3.9`
- `Medium`: `4.0 - 6.9`
- `High`: `7.0 - 8.9`
- `Critical`: `9.0 - 10.0`

Important nuance:

- CVSS is a starting point, not final business risk.
- A `High` CVE in an unreachable package path may be lower priority than a `Medium` exposed auth bypass on an internet-facing service.

## Risk Prioritization (Practical Triage)

Prioritize based on *severity + exploitability + exposure + business impact*.

Recommended triage order:

1. Internet-facing critical/high vulnerabilities in production paths
2. Secrets exposure (immediate rotate + revoke)
3. Runtime container/image CVEs in deployed services
4. Build-time/dev-only dependency vulnerabilities
5. Low-impact findings / non-exploitable paths / documented exceptions

Use context questions:

- Is the vulnerable component deployed?
- Is the code path reachable?
- Is there a public exploit?
- Is the service internet-facing?
- Is compensating control present (WAF, auth, network isolation)?

## Patch Management Strategy (DevSecOps)

Use a layered patch strategy instead of ad-hoc upgrades.

### 1. Continuous Detection

- CI scans on PRs and merges
- scheduled SAST/dependency scans
- runtime image scans before publish/deploy

### 2. Prioritized Remediation Windows

- Critical: same day / emergency patch window
- High: next sprint or within policy SLA
- Medium: regular maintenance cycle
- Low: backlog or opportunistic updates

### 3. Safe Upgrade Process

1. patch in dev
2. test + scan
3. promote exact artifact/version to staging
4. validate
5. promote exact artifact/version to prod

### 4. Exception Handling

If not patching immediately:

- document reason
- add compensating control
- set review expiration date
- track in risk register / ticket

## Notes

- This is a template lab. Some scanners rely on real dependencies, lockfiles, and registry access in a live GitHub repo run.
- For production, pin actions by commit SHA and add policy controls (CODEOWNERS, branch protection, environment approvals).
