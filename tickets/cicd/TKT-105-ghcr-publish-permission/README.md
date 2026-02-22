# TKT-105: GHCR Publish Permission Denied

Reproduce by removing `packages: write` in `docker-publish.yml`.

Debug: inspect publish step logs and verify `ghcr.io` login and image name.

Fix: restore `packages: write` and push a new version tag.
