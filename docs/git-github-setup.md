# Git + GitHub Push Setup (Why your changes may not be pushing)

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
