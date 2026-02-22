# GitHub Actions CI/CD Lab Notes

## Enterprise Program Standard

This module is part of a professional infrastructure training program (not a hobby lab).

Training expectations for this module:
- production-grade design and operational assumptions (multi-AZ/region, identity, logging, recovery)
- security controls and least-privilege decisions are part of the exercise, not optional add-ons
- audit awareness: change traceability, approvals, evidence, and rollback records should be captured
- failure domain analysis must be included (process, host/node, AZ/region, dependency, control plane)
- examples are learning-safe but mapped to enterprise patterns; avoid localhost-only reasoning during analysis
- exercises are repeatable without AI by following the documented commands, checklists, and runbooks

Template project: `projects/github-actions-ci-demo/`

Pipeline stages:

1. Lint
2. Test (matrix)
3. Build
4. Docker build verify
5. Semantic release tag
6. Docker publish on `v*.*.*`

Production controls:

- Branch protection on `main`
- Least-privilege workflow permissions
- `concurrency` and `fail-fast`
- GitHub Environments for deployment secrets/approvals
