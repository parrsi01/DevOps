# Exercise 1.3 — Filesystem Navigation & Log Reading

## Commands Run
```bash
cd /var/log
ls -lh
tail -20 syslog
```

## Evidence

### ls -lh key observations
- syslog: 9.2M, owned by syslog:adm, permissions rw-r----- (adm group read-only, others no access)
- auth.log: 542K — SSH login attempts, sudo events
- kern.log: 3.7M — kernel messages
- Log rotation in action: syslog, syslog.1, syslog.2.gz (older = compressed)

### tail -20 syslog key entries
- NetworkManager DHCP lease: address=192.168.64.2 — network interface came up
- systemd-resolved reset DNS search domain after DHCP change
- sysstat-collect.service fired — scheduled system stats (cron-triggered)
- vsce-sign verified VS Code extension signatures

## Key Concepts
- /var/log is the primary incident investigation location
- Log files rotate: current → .1 → .2.gz → deleted
- Permission rw-r----- means owner=rw, group=r, others=none
- syslog:adm ownership means you need adm group membership or sudo to read

## Real-World Application
> When something breaks at 3am: `tail -f /var/log/syslog` and `tail -f /var/log/auth.log` are your first commands.
