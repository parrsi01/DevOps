./scripts/capture_http_timeout.sh api.company.aero 443 eth0
tracepath api.company.aero
ping -M do -s 1472 api.company.aero
ping -M do -s 1400 api.company.aero
