# Git + GitHub Push Setup (Why your changes may not be pushing)

## Enterprise Program Standard

This module is part of a professional infrastructure training program (not a hobby lab).

Training expectations for this module:
- production-grade design and operational assumptions (multi-AZ/region, identity, logging, recovery)
- security controls and least-privilege decisions are part of the exercise, not optional add-ons
- audit awareness: change traceability, approvals, evidence, and rollback records should be captured
- failure domain analysis must be included (process, host/node, AZ/region, dependency, control plane)
- examples are learning-safe but mapped to enterprise patterns; avoid localhost-only reasoning during analysis
- exercises are repeatable without AI by following the documented commands, checklists, and runbooks

Common blockers:

- Folder is not a git repository (`git init` not run)
- No remote configured (`git remote -v` empty)
- No Git identity configured (`user.name`, `user.email`)
- GitHub auth missing/expired (`gh auth status`)
- You made local edits but never committed them

Quick commands:

```bash
git status
git remote -v
git config --get user.name
git config --get user.email
gh auth status
```
