# DevSecOps CI/CD Integration Lab Notes

Author: Simon Parris  
Date: 2026-02-22

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
