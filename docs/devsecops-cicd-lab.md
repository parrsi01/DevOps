# DevSecOps CI/CD Integration Lab Notes

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

Target project: `projects/github-actions-ci-demo/`

Covers:

- Trivy container scanning
- dependency vulnerability scanning
- secrets scanning
- SAST (basic CodeQL integration)
- Docker image hardening (minimal base + non-root)
- security headers verification
- simulations:
  - vulnerable dependency
  - hardcoded secret detection
  - critical CVE in base image
  - insecure Dockerfile pattern
- CVSS scoring, risk prioritization, patch management strategy

Start here:

```bash
cd projects/github-actions-ci-demo
# review workflows and secure-nginx example
ls .github/workflows
ls examples/secure-nginx
```
