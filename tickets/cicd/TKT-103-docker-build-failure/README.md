# TKT-103: Docker Build Verify Failure

Reproduce by breaking a `COPY` path in `Dockerfile`.

Debug: inspect `docker-build-verify` job logs and run `docker build -t local-debug .` locally.

Fix: correct file paths or `.dockerignore` exclusions.
