#!/usr/bin/env bash
set -euo pipefail


# Block 1 from 01-linux-mastery
cd /home/sp/cyber-course/projects/DevOps
sed -n '1,120p' docs/linux-mastery-lab.md


# Block 2 from 01-linux-mastery
whoami
uname -a
ip a | head -40
ss -tulpn | head -30
df -h
free -h


# Block 3 from 01-linux-mastery
mkdir -p /tmp/devops-linux-lab
cd /tmp/devops-linux-lab
printf 'hello\n' > demo.txt
ls -l demo.txt
chmod 600 demo.txt
ls -l demo.txt
chmod 644 demo.txt
ls -l demo.txt


# Block 4 from 01-linux-mastery
sleep 600 &
SLEEP_PID=$!
echo "$SLEEP_PID"
ps -p "$SLEEP_PID" -o pid,ppid,cmd
systemctl status systemd-journald --no-pager
journalctl -n 50 --no-pager
kill "$SLEEP_PID"


# Block 5 from 01-linux-mastery
ps -ef | rg 'sleep 600' || true
ss -tulpn | head -20
journalctl -p err -n 20 --no-pager
rm -rf /tmp/devops-linux-lab

