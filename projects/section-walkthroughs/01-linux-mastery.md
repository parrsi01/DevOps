# Section 1 - Linux Mastery

Source docs:

- `docs/linux-mastery-lab.md`

## What Type Of Software Engineering This Is

Systems engineering and operations engineering. You are learning how the host OS behaves so later Docker/Kubernetes/CI failures are not random.

## Definitions

- `process`: a running program instance.
- `service`: a managed long-running process (usually controlled by `systemctl`).
- `journal`: system logs stored by `systemd-journald` (view with `journalctl`).
- `port`: a network listening endpoint (for example `:8080`).
- `permissions`: read/write/execute access rules for users/groups/files.

## Concepts And Theme

Build an evidence-first debugging habit on Linux before touching higher layers.

## 1. Step 1 - Read the module and scope the practice

```bash
cd /home/sp/cyber-course/projects/DevOps
sed -n '1,120p' docs/linux-mastery-lab.md
```

What you are doing: opening the source notes so you know the topics (permissions, processes, logs, networking, disk, memory, ports).

## 2. Step 2 - Capture baseline host evidence

```bash
whoami
uname -a
ip a | head -40
ss -tulpn | head -30
df -h
free -h
```

What you are doing: collecting a snapshot of identity, OS, interfaces, listening ports, disk, and memory before changing anything.

## 3. Step 3 - Practice file permissions on a safe test file

```bash
mkdir -p /tmp/devops-linux-lab
cd /tmp/devops-linux-lab
printf 'hello\n' > demo.txt
ls -l demo.txt
chmod 600 demo.txt
ls -l demo.txt
chmod 644 demo.txt
ls -l demo.txt
```

What you are doing: changing file permissions and verifying the result with `ls -l` so you can read `-rw-------` vs `-rw-r--r--` quickly.

## 4. Step 4 - Practice process + service + logs

```bash
sleep 600 &
SLEEP_PID=$!
echo "$SLEEP_PID"
ps -p "$SLEEP_PID" -o pid,ppid,cmd
systemctl status systemd-journald --no-pager
journalctl -n 50 --no-pager
kill "$SLEEP_PID"
```

What you are doing: creating one harmless process, checking one real service, and reading recent logs so you can tell the difference between process, service, and log evidence.

## 5. Step 5 - Validate cleanup and summarize symptoms by layer

```bash
ps -ef | rg 'sleep 600' || true
ss -tulpn | head -20
journalctl -p err -n 20 --no-pager
rm -rf /tmp/devops-linux-lab
```

What you are doing: confirming your test process is gone, re-checking ports, and reviewing recent errors without changing anything.

## Done Check

You can explain (in one sentence each):

- process problem
- service problem
- port problem
- permission problem
- log evidence vs guesswork
