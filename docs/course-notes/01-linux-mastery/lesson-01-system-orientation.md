# Chapter 1 — Linux Mastery
## Lesson 1 — System Orientation

Author: Simon Parris
Date: 2026-03-06

---

## Commands Run

```bash
whoami
uname -a
ip a | head -40
ss -tulpn | head -30
df -h
free -h
```

## Output

```
whoami        → root
uname -a      → Linux runsc 4.4.0 #1 SMP x86_64 GNU/Linux
ip a          → command not found (iproute2 not installed in sandbox)
ss -tulpn     → command not found (iproute2 not installed in sandbox)

df -h:
  /opt/env-runner    13M / 13M  100%  (read-only overlay)
  /opt/claude-code   66M / 66M  100%  (read-only overlay)
  none (main /  )    30G / 6.6M   1%  (healthy)

free -h:
  Mem:  21Gi total | 473Mi used | 20Gi available
  Swap: 0B
```

## Analysis

| Check | Result | Notes |
|---|---|---|
| User | root | Full privileges — use named user + sudo in production |
| Kernel | 4.4.0 x86_64 | Old kernel, gVisor sandbox environment (runsc) |
| Network interfaces | N/A | iproute2 not installed in container |
| Open ports | N/A | ss not available — on real server use ss -tulpn |
| Disk pressure | Two mounts at 100% | Read-only system overlays, not writable — main disk healthy |
| RAM | 20Gi available | No swap — normal for containers, no memory pressure |

## Key Takeaways

- Always identify your user before acting — root means no guardrails
- Kernel version tells you what features and syscalls are available
- Disk at 100% on a writable partition = immediate incident — here it is safe (read-only overlays)
- No swap in a container is expected; on a VM it warrants investigation
- `ip a` and `ss -tulpn` are standard on any real Ubuntu/Debian/RHEL server (iproute2 package)

## Production Habit

Before touching any server:
1. `whoami` — confirm identity
2. `uname -a` — confirm kernel/arch
3. `ip a` — know the network layout
4. `ss -tulpn` — know what is already listening
5. `df -h` — check for full disks
6. `free -h` — check memory headroom
