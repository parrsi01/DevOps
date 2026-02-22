#!/usr/bin/env sh
set -eu

if [ "${CRASH_ON_START:-0}" = "1" ]; then
  echo "Intentional startup crash for lab simulation"
  exit 42
fi

if [ "${WRITE_PROBE_FILE:-0}" = "1" ]; then
  : "${DATA_DIR:=/data}"
  mkdir -p "$DATA_DIR"
  date > "$DATA_DIR/startup.probe"
fi

exec "$@"
