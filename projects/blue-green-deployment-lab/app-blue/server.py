# Author: Simon Parris
# Date: 2026-02-22
import json
import os
import threading
from http.server import BaseHTTPRequestHandler, ThreadingHTTPServer
from pathlib import Path
from urllib.parse import parse_qs, urlparse

APP_VERSION = "blue-v1"
MAX_SCHEMA_SUPPORTED = 1
PORT = int(os.getenv("PORT", "8080"))
DATA_DIR = Path(os.getenv("DATA_DIR", "/data"))
STATE_FILE = DATA_DIR / "state.json"
lock = threading.Lock()


def ensure_state():
    DATA_DIR.mkdir(parents=True, exist_ok=True)
    if not STATE_FILE.exists():
        STATE_FILE.write_text(json.dumps({"schema_version": 1, "request_count": 0, "last_writer": APP_VERSION}), encoding="utf-8")


def read_state():
    ensure_state()
    with lock:
        return json.loads(STATE_FILE.read_text(encoding="utf-8"))


def write_state(state):
    ensure_state()
    with lock:
        STATE_FILE.write_text(json.dumps(state), encoding="utf-8")


def is_forced_bad():
    return os.getenv("FORCE_BAD", "0") == "1" or Path("/tmp/force_bad").exists()


def schema_compatible(state):
    return int(state.get("schema_version", 1)) <= MAX_SCHEMA_SUPPORTED


class Handler(BaseHTTPRequestHandler):
    server_version = "BlueGreenLab/1.0"

    def _json(self, status, payload):
        body = json.dumps(payload).encode("utf-8")
        self.send_response(status)
        self.send_header("Content-Type", "application/json")
        self.send_header("Content-Length", str(len(body)))
        self.end_headers()
        self.wfile.write(body)

    def log_message(self, fmt, *args):
        # keep logs concise but visible via docker logs
        print(f"{self.address_string()} - - [{self.log_date_time_string()}] {fmt % args}")

    def do_GET(self):
        parsed = urlparse(self.path)
        if parsed.path == "/health":
            state = read_state()
            if is_forced_bad():
                return self._json(500, {"status": "bad", "reason": "forced_bad_mode", "version": APP_VERSION})
            if not schema_compatible(state):
                return self._json(500, {"status": "bad", "reason": "schema_incompatible", "schema_version": state.get("schema_version"), "version": APP_VERSION})
            return self._json(200, {"status": "ok", "version": APP_VERSION})

        if parsed.path == "/":
            state = read_state()
            if is_forced_bad():
                return self._json(500, {"error": "forced_bad_mode", "version": APP_VERSION})
            if not schema_compatible(state):
                return self._json(500, {
                    "error": "schema_incompatible",
                    "supported_max_schema": MAX_SCHEMA_SUPPORTED,
                    "found_schema": state.get("schema_version"),
                    "version": APP_VERSION,
                })
            state["request_count"] = int(state.get("request_count", 0)) + 1
            state["last_writer"] = APP_VERSION
            write_state(state)
            return self._json(200, {
                "version": APP_VERSION,
                "schema_version": state.get("schema_version", 1),
                "request_count": state["request_count"],
                "last_writer": state["last_writer"],
            })

        if parsed.path == "/state":
            state = read_state()
            return self._json(200, {"version": APP_VERSION, "state": state})

        if parsed.path == "/control/bad":
            q = parse_qs(parsed.query)
            enabled = q.get("enabled", ["1"])[0]
            bad_file = Path("/tmp/force_bad")
            if enabled in ("1", "true", "yes"):
                bad_file.write_text("1", encoding="utf-8")
            else:
                if bad_file.exists():
                    bad_file.unlink()
            return self._json(200, {"version": APP_VERSION, "forced_bad": bad_file.exists()})

        # blue can write schema 1 only (rollback-safe writer)
        if parsed.path == "/control/migrate":
            q = parse_qs(parsed.query)
            target = int(q.get("schema", ["1"])[0])
            if target > MAX_SCHEMA_SUPPORTED:
                return self._json(400, {"error": "unsupported_schema_for_version", "version": APP_VERSION, "max": MAX_SCHEMA_SUPPORTED})
            state = read_state()
            state["schema_version"] = target
            state["last_writer"] = APP_VERSION
            write_state(state)
            return self._json(200, {"version": APP_VERSION, "schema_version": target})

        self._json(404, {"error": "not_found", "path": parsed.path, "version": APP_VERSION})


if __name__ == "__main__":
    ensure_state()
    print(f"Starting {APP_VERSION} on :{PORT}")
    ThreadingHTTPServer(("0.0.0.0", PORT), Handler).serve_forever()
