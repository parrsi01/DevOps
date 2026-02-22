# GitHub Actions CI/CD Demo (Production Template)

This folder contains a production-style GitHub Actions pipeline skeleton with:

- `lint` -> `test` -> `build` -> `docker-build-verify`
- semantic version tagging via `semantic-release`
- Docker publish on version tags to `ghcr.io`

## Use it

1. Copy these files into your app repo (or adapt this folder into a real app).
2. Enable branch protection on `main`.
3. Use Conventional Commits (`feat:`, `fix:`).
4. Push and inspect GitHub Actions runs.
