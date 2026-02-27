# Exercise 1.7 — Module 01 Full Run (block-02 through block-05)

## Block 02 — System Orientation
```
whoami → sp
uname  → Linux ubuntu-server 6.8.0-101-generic aarch64
```

### Network interfaces (ip a)
| Interface | Address | Notes |
|-----------|---------|-------|
| lo | 127.0.0.1/8 | loopback |
| enp0s1 | 192.168.64.2/24 | main NIC, DHCP |
| docker0 | 172.17.0.1/16 | Docker bridge |
| sw-wg | (no IP) | SecureWave WireGuard tunnel |
| veth* (x4) | link-local only | Docker container veth pairs |

### Open ports (ss -tulpn)
| Port | Proto | Process | Notes |
|------|-------|---------|-------|
| 22 | tcp | sshd | SSH |
| 8000 | tcp | uvicorn | SecureWave backend |
| 8080 | tcp | uvicorn/python | SecureWave preview site |
| 9443 | tcp | unknown | HTTPS alt |
| 53 | udp/tcp | systemd-resolved | DNS |
| 500/4500 | udp | strongSwan | IKEv2 VPN |

### Disk (df -h)
- Root volume: 57G used / 96G total (63%) — healthy
- Boot: 208M / 2G

### Memory (free -h)
- RAM: 3.9G used / 5.8G total
- Swap: 2.7G used / 4G — memory pressure, swap active

## Block 03 — File Permissions
```
touch demo.txt → -rw-rw-r-- (664 default)
chmod 600      → -rw------- (private)
chmod 644      → -rw-r--r-- (public read)
```

## Block 04 — Process & Service Management
- Spawned sleep 600 background process, captured PID
- ps confirmed PID with parent relationship
- systemctl status systemd-journald → active (running) since Feb 26, uptime 1d+
- journalctl showed: CRON jobs, gnome-keyring duplicate registrations, sudo failures (expected from non-interactive terminal)
- kill $SLEEP_PID → process terminated cleanly

## Block 05 — Cleanup & Port Scan
- `rg` not installed (ripgrep missing) — non-critical, grep is equivalent
- ss -tulpn confirmed same open ports as block-02
- journalctl -p err showed sudo auth failures from non-interactive terminal sessions (this course)
- /tmp/devops-linux-lab cleaned up

## Issues Found
| Issue | Severity | Action |
|-------|----------|--------|
| rg not installed | Low | `sudo apt install ripgrep` when in manual terminal |
| Swap 2.7G/4G used | Medium | Monitor — close Firefox/VS Code tabs if degrading |
| sudo fails in Claude terminal | Expected | Use manual terminal for sudo commands |

## Key Learnings
- ip a shows all network interfaces including Docker bridges and VPN tunnels
- ss -tulpn is the modern replacement for netstat (shows listening sockets + process names)
- systemctl status works without sudo for read-only service inspection
- journalctl -p err filters only error-level log entries
- background process pattern: `cmd &` → capture `$!` → inspect → `kill $!`
