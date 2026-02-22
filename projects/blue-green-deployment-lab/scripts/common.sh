#!/usr/bin/env bash
# Author: Simon Parris
# Date: 2026-02-22
set -euo pipefail

PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
COMPOSE_FILE="$PROJECT_DIR/compose.yaml"
TEMPLATE_FILE="$PROJECT_DIR/nginx/templates/default.conf.tpl"
GENERATED_FILE="$PROJECT_DIR/nginx/generated/default.conf"
DATA_DIR="$PROJECT_DIR/data"

log() {
  printf '[%s] %s\n' "$(date +%H:%M:%S)" "$*"
}

dc() {
  docker compose -f "$COMPOSE_FILE" "$@"
}

ensure_dirs() {
  mkdir -p "$DATA_DIR" "$PROJECT_DIR/nginx/generated"
}

render_nginx_config() {
  local green_pct="${1:-0}"
  if [[ ! "$green_pct" =~ ^[0-9]+$ ]] || (( green_pct < 0 || green_pct > 100 )); then
    echo "green percentage must be an integer from 0 to 100" >&2
    return 1
  fi

  local blue_pct=$((100 - green_pct))
  local upstream_servers=""

  if (( blue_pct > 0 )); then
    upstream_servers+="    server app_blue:8080 weight=${blue_pct} max_fails=1 fail_timeout=3s;"
    upstream_servers+=$'\n'
  fi
  if (( green_pct > 0 )); then
    upstream_servers+="    server app_green:8080 weight=${green_pct} max_fails=1 fail_timeout=3s;"
    upstream_servers+=$'\n'
  fi

  if [[ -z "$upstream_servers" ]]; then
    echo "at least one backend must have traffic" >&2
    return 1
  fi

  python3 - "$TEMPLATE_FILE" "$GENERATED_FILE" "$upstream_servers" "$blue_pct" "$green_pct" <<'PY'
import sys
from pathlib import Path

tpl = Path(sys.argv[1]).read_text(encoding='utf-8')
out = Path(sys.argv[2])
servers = sys.argv[3].rstrip('\n')
blue = sys.argv[4]
green = sys.argv[5]
text = tpl.replace('__UPSTREAM_SERVERS__', servers)
text = text.replace('__BLUE_WEIGHT__', blue)
text = text.replace('__GREEN_WEIGHT__', green)
out.write_text(text, encoding='utf-8')
PY
}

reload_nginx() {
  if dc ps --status running --services 2>/dev/null | grep -qx nginx; then
    log "Reloading nginx"
    dc exec -T nginx nginx -s reload >/dev/null
  else
    log "nginx container not running yet; config will be used on next start"
  fi
}

set_routing() {
  local green_pct="${1:-0}"
  ensure_dirs
  render_nginx_config "$green_pct"
  reload_nginx
  log "Routing updated: blue=$((100 - green_pct)) green=$green_pct"
}

curl_json_field() {
  local url="$1"
  local field="$2"
  curl -sS "$url" | python3 -c "import json,sys; print(json.load(sys.stdin).get('$field',''))"
}

backend_url() {
  case "${1:-}" in
    blue) echo "http://127.0.0.1:18081" ;;
    green) echo "http://127.0.0.1:18082" ;;
    proxy) echo "http://127.0.0.1:8088" ;;
    *) echo "unknown backend '$1'" >&2; return 1 ;;
  esac
}

check_backend_health() {
  local target="$1"
  local url
  url="$(backend_url "$target")/health"
  local body
  if ! body="$(curl -sS -m 2 -w '\n%{http_code}' "$url")"; then
    echo "unreachable"
    return 1
  fi
  local code="${body##*$'\n'}"
  local payload="${body%$'\n'*}"
  echo "$payload"
  [[ "$code" == "200" ]]
}
