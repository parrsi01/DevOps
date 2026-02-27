# Exercise 1.6 — Process Management

## Commands Run
```bash
ps aux | head -20
ps aux | grep python3
top -b -n1 | head -20
pstree -p | head -20
pgrep -a python3
```

## Evidence

### System state (top snapshot)
- Uptime: 1 day
- Load average: 2.96, 2.56, 1.87 (high — 2 CPUs, consistently above 2.0)
- RAM: 3.9GB / 5.9GB used, 2.7GB swap in use (memory pressure)
- 1 zombie process present

### Top CPU consumers
| PID    | Process    | CPU%  | Notes                        |
|--------|------------|-------|------------------------------|
| 3302   | gnome-shell| 263%  | Desktop compositor running hot|
| 414256 | claude     | 36%   | This session                 |
| 4119   | code       | 9%    | VS Code                      |
| 30356  | firefox    | 9%    | Browser                      |
| 443154 | uvicorn    | 0.2%  | SecureWave FastAPI backend   |

### Python3 processes found
- PID 1401 (root): unattended-upgrades shutdown watcher
- PID 3900 (sp): caffeine (screen-off preventer)
- PID 443154 (sp): uvicorn serving SecureWave on port 8000

### pstree
- All processes descend from systemd(1) — PID 1 on modern Ubuntu
- containerd running (Docker daemon present)
- NetworkManager, ModemManager, avahi all systemd children

## STAT codes reference
| Code | Meaning |
|------|---------|
| S | Sleeping (waiting) — normal |
| R | Running (using CPU) |
| Z | Zombie (finished, parent not collected) |
| s | Session leader |
| l | Multi-threaded |

## Kill reference
```bash
kill <PID>      # SIGTERM — graceful, app cleans up
kill -9 <PID>   # SIGKILL — force, no cleanup (last resort)
pkill nginx     # kill by process name
killall python3 # kill all matching
```

## Key Concepts
- Always try SIGTERM first, give 5s, then SIGKILL
- Zombie processes = finished but parent hasn't called wait() — usually harmless unless accumulating
- High swap usage = memory pressure — investigate top consumers
- pstree shows parent/child relationships — useful for finding what spawned a runaway process
