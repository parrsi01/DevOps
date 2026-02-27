# Exercise 1.5 — Users, Groups & Ownership

## Commands Run
```bash
id
cat /etc/passwd | cut -d: -f1
cat /etc/group | cut -d: -f1
sudo chown root:root /tmp/app-data   # simulate broken state
sudo chown sp:sp /tmp/app-data       # fix
ls -lhd /tmp/app-data
```

## Evidence

### id output
uid=1000(sp) gid=1000(sp) groups=1000(sp),4(adm),24(cdrom),27(sudo),30(dip),46(plugdev),101(lxd),986(docker)

### Key group memberships
- adm    → read /var/log without sudo
- sudo   → can escalate with sudo
- docker → run docker without sudo

### sudo in non-interactive terminal
- sudo requires interactive TTY for password input
- Workaround: SSH into server, configure NOPASSWD sudoers for specific commands, or run scripts as correct user

## chown Reference
```bash
chown user:group file         # change owner and group
chown -R user:group dir/      # recursive
chown www-data:www-data /var/www   # web server pattern
chown deploy:deploy /opt/app       # deploy user pattern
```

## Incident Pattern
> App fails with "permission denied" on data dir:
> 1. ls -lhd /var/app/data      → who owns it?
> 2. ps aux | grep appname      → what user is the process?
> 3. sudo chown appuser:appuser /var/app/data

## Key Concepts
- Every process runs as a user — that user's permissions determine file access
- Group membership = additional access without ownership
- chown fixes ownership, chmod fixes permissions — you often need both
- /etc/passwd = user list, /etc/group = group list
