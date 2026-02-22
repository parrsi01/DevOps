# GitHub Actions CI/CD Lab Notes

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
