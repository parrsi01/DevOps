ps -ef | rg 'sleep 600' || true
ss -tulpn | head -20
journalctl -p err -n 20 --no-pager
rm -rf /tmp/devops-linux-lab
