# Linux and System Administration

---

> **Field** — DevOps / Systems Administration
> **Scope** — Operating system fundamentals that underpin all DevOps tooling

---

## Overview

Linux is the foundation layer for Docker, Kubernetes,
CI/CD, and monitoring. Every DevOps tool runs on top
of Linux processes, permissions, networking, and
storage. Weakness here makes every later module
harder to debug.

---

## Definitions

### `Permission`

**Definition.**
A rule that controls who can read, write, or execute
a file or directory. Linux uses a three-tier model:
owner, group, and others.

**Context.**
Permission errors are one of the most common causes
of container failures, service startup issues, and
deployment problems. Always check permissions early.

**Example.**
```bash
ls -l /var/log/app.log
# -rw-r----- 1 root adm 4096 Feb 23 app.log
# owner: read+write, group: read, others: none

chmod 644 /var/log/app.log
# now: owner read+write, group read, others read
```

---

### `Process`

**Definition.**
A running program instance. Every command you run
creates at least one process. Processes have a
process ID (PID), a parent, and resource usage.

**Context.**
When a service behaves unexpectedly, checking its
process state reveals whether it is running, stopped,
consuming too much memory, or stuck.

**Example.**
```bash
ps aux | grep nginx
# shows all nginx processes, their PID, CPU, memory

kill 12345
# sends a termination signal to process 12345
```

---

### `Service`

**Definition.**
A managed long-running program, usually controlled
by systemd on modern Linux systems. Services can
be started, stopped, enabled (auto-start on boot),
or disabled.

**Context.**
Services are how production software runs. Checking
service status is often the first debugging step
for infrastructure issues.

**Example.**
```bash
systemctl status nginx
# shows running/stopped, recent logs, PID

systemctl restart nginx
# stops and starts the service

systemctl enable nginx
# auto-start on boot
```

---

### `Port`

**Definition.**
A numbered network endpoint that a program listens
on for incoming connections. Port numbers range
from 0 to 65535. Well-known ports include 80 (HTTP),
443 (HTTPS), and 22 (SSH).

**Context.**
Port conflicts (two programs trying to use the same
port) are a common cause of service startup failures.
Checking which ports are in use is a key debugging step.

**Example.**
```bash
ss -tulpn
# shows all listening TCP/UDP ports and which
# process owns each one

ss -tulpn | grep :8080
# check if anything is listening on port 8080
```

---

### `Journal`

**Definition.**
System log storage managed by systemd-journald.
The journal captures logs from all services,
the kernel, and system events in a structured,
searchable format.

**Context.**
When a service fails to start or crashes, the
journal contains the error messages and timestamps
needed to understand what happened.

**Example.**
```bash
journalctl -u nginx -n 50 --no-pager
# last 50 log lines for the nginx service

journalctl --since "10 minutes ago"
# all system logs from the last 10 minutes
```

---

### `systemd`

**Definition.**
The init system and service manager used by most
modern Linux distributions. It starts services,
manages dependencies between them, and provides
logging through journald.

**Context.**
Understanding systemd is essential because it
controls how every service on the system starts,
stops, and reports its health.

**Example.**
```bash
systemctl list-units --type=service --state=running
# lists all currently running services
```

---

### `File System`

**Definition.**
The organized structure of directories and files
on a Linux system. Key directories include `/etc`
(configuration), `/var` (variable data like logs),
and `/home` (user files).

**Context.**
Knowing where configuration files, logs, and data
live on the file system is essential for debugging
and for understanding container volume mounts.

**Example.**
```bash
df -h
# shows disk usage per mounted filesystem

du -sh /var/log
# shows total size of the log directory
```

---

### `Environment Variable`

**Definition.**
A named value available to all processes in a
session. Programs use environment variables for
configuration like database URLs, API keys,
and feature flags.

**Context.**
Misconfigured environment variables are a frequent
cause of application failures, especially in
containers where configuration is injected this way.

**Example.**
```bash
echo $PATH
# shows the directories searched for commands

export DATABASE_URL="postgres://localhost:5432/mydb"
# sets a variable for the current session
```

---

### `User and Group`

**Definition.**
Linux organizes access control around users and
groups. Each file is owned by a user and a group.
Processes run as a specific user, which determines
what they can access.

**Context.**
Running containers or services as root is a security
risk. Production systems use dedicated service
accounts with minimal permissions.

**Example.**
```bash
whoami
# shows current user

id
# shows user ID, group ID, and group memberships

groups sp
# shows all groups user "sp" belongs to
```

---

### `Resource Exhaustion`

**Definition.**
A condition where a system runs out of a critical
resource like CPU, memory, disk space, or file
descriptors. This causes processes to slow down,
crash, or refuse new connections.

**Context.**
Resource exhaustion is a common root cause for
"the app just stopped working" incidents. Checking
resource usage is a standard early debugging step.

**Example.**
```bash
free -h
# shows memory usage (total, used, available)

df -h
# shows disk space per filesystem

top
# live view of CPU and memory per process
```

---

### `Network Reachability`

**Definition.**
Whether one machine or process can successfully
communicate with another over the network. This
depends on DNS, routing, firewalls, and the
target service being up.

**Context.**
"Cannot connect" errors require layered diagnosis:
is DNS working, is the route open, is the port
listening, is the firewall allowing traffic?

**Example.**
```bash
ping 8.8.8.8
# basic network connectivity test

curl -v http://127.0.0.1:8080/health
# verbose HTTP request showing connection details
```

---

## Key Commands Summary

```bash
# Identity and system info
whoami
uname -a
hostname

# Process management
ps aux
kill <PID>
top

# Service management
systemctl status <service>
systemctl start <service>
systemctl stop <service>
systemctl restart <service>
systemctl enable <service>

# Log inspection
journalctl -u <service> -n 50 --no-pager
journalctl --since "10 minutes ago"

# Network and ports
ip a
ss -tulpn
ping <host>
curl -v <url>

# Disk and memory
df -h
free -h
du -sh <directory>

# Permissions
ls -la
chmod <mode> <file>
chown <user>:<group> <file>
```

---

## See Also

- [Universal DevOps Concepts](./00_universal_devops_concepts.md)
- [Containers and Docker](./02_containers_and_docker.md)
- [Networking and Enterprise Infrastructure](./10_networking_and_enterprise_infrastructure.md)

---

> **Author** — Simon Parris | DevOps Reference Library
