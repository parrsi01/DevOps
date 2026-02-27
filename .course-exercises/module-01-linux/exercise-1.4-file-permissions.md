# Exercise 1.4 — File Permissions

## Commands Run
```bash
echo "secret config" > test-config.txt
ls -lh test-config.txt          # -rw-rw-r-- (default umask)
chmod 000 test-config.txt
cat test-config.txt             # Permission denied
chmod 640 test-config.txt
ls -lh test-config.txt          # -rw-r-----
cat test-config.txt             # secret config
```

## Evidence
- Default created file: -rw-rw-r-- (664)
- chmod 000: cat returns "Permission denied" — owner locked out
- chmod 640: owner rw, group r, others none — correct for config files

## Permission Number Reference
| chmod | Symbolic   | Use case              |
|-------|------------|-----------------------|
| 600   | rw-------  | .env, private keys    |
| 640   | rw-r-----  | app config files      |
| 644   | rw-r--r--  | public web assets     |
| 755   | rwxr-xr-x  | scripts, directories  |
| 700   | rwx------  | private scripts       |
| 777   | rwxrwxrwx  | NEVER in production   |

## Key Concepts
- Three sets: owner / group / others
- r=4, w=2, x=1 — add them for each set
- "Permission denied" on app config = check file owner, file group, process user
- chmod 000 locks out even the owner (need sudo or root to recover)

## Real-World Application
> App can't read config at startup → ls -lh config → check owner:group → check what user the service runs as → chmod/chown to fix
