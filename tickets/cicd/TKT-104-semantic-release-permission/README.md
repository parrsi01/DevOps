# TKT-104: Semantic Release Tagging Failure (403)

Reproduce by removing `contents: write` in `release-tag.yml`.

Debug: check `semantic-release` logs for permission errors or missing tags/history.

Fix: restore `permissions.contents: write` and `actions/checkout` `fetch-depth: 0`.
