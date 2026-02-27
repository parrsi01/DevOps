cd /home/sp/cyber-course/projects/DevOps/projects/github-actions-ci-demo
ls .github/workflows
rg -n '^(name:|on:|permissions:|jobs:|\s{2}[a-zA-Z0-9_-]+:|\s+needs:)' .github/workflows/*.yml
