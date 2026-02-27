sleep 600 &
SLEEP_PID=$!
echo "$SLEEP_PID"
ps -p "$SLEEP_PID" -o pid,ppid,cmd
systemctl status systemd-journald --no-pager
journalctl -n 50 --no-pager
kill "$SLEEP_PID"
