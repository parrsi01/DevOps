# Secure Nginx Example (DevSecOps CI/CD Scan Target)

Author: Simon Parris  
Date: 2026-02-22

Purpose:

- provide a concrete Docker image for Trivy container scanning in CI
- demonstrate Docker hardening patterns (minimal base, non-root runtime)
- validate HTTP security headers in CI
- provide `Dockerfile.insecure` for security simulation drills

## Files

- `Dockerfile` - hardened example
- `Dockerfile.insecure` - intentionally insecure patterns for simulation
- `nginx.conf` - baseline security headers
- `index.html` - static content
