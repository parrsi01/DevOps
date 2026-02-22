import logging
import os
import threading
import time
from datetime import datetime, timezone
from pathlib import Path

from flask import Flask, Response, jsonify, request
from prometheus_client import (
    CONTENT_TYPE_LATEST,
    Counter,
    Gauge,
    Histogram,
    generate_latest,
)

app = Flask(__name__)
log_dir = Path(os.getenv("APP_LOG_DIR", "/var/log/monitoring-lab"))
log_dir.mkdir(parents=True, exist_ok=True)
log_file = log_dir / "app.log"

logging.basicConfig(
    level=os.getenv("LOG_LEVEL", "INFO"),
    format="%(asctime)s %(levelname)s %(message)s",
    handlers=[
        logging.StreamHandler(),
        logging.FileHandler(log_file, encoding="utf-8"),
    ],
)
logger = logging.getLogger("monitoring-lab")

REQUESTS_TOTAL = Counter(
    "app_http_requests_total",
    "Total HTTP requests handled by the app",
    ["method", "route", "status"],
)
REQUEST_DURATION = Histogram(
    "app_http_request_duration_seconds",
    "HTTP request duration",
    ["method", "route", "status"],
    buckets=(0.005, 0.01, 0.025, 0.05, 0.1, 0.25, 0.5, 1, 2, 5),
)
ERRORS_TOTAL = Counter(
    "app_errors_total",
    "Application-level errors",
    ["type"],
)
DB_QUERY_LATENCY = Histogram(
    "app_db_query_latency_seconds",
    "Simulated DB query latency",
    ["operation"],
    buckets=(0.005, 0.01, 0.025, 0.05, 0.1, 0.25, 0.5, 1, 2, 5, 10),
)
INFLIGHT_REQUESTS = Gauge(
    "app_inflight_requests",
    "In-flight HTTP requests",
)
MEMORY_SPIKE_ACTIVE = Gauge(
    "app_memory_spike_active",
    "Whether a synthetic memory spike is active",
)
CPU_SPIKE_ACTIVE = Gauge(
    "app_cpu_spike_active",
    "Whether a synthetic CPU spike is active",
)

_memory_hold = []
_spike_lock = threading.Lock()


@app.before_request
def before_request():
    INFLIGHT_REQUESTS.inc()
    request._start_ts = time.perf_counter()


@app.after_request
def after_request(response):
    route = request.url_rule.rule if request.url_rule else request.path
    status = str(response.status_code)
    duration = max(time.perf_counter() - getattr(request, "_start_ts", time.perf_counter()), 0)
    REQUESTS_TOTAL.labels(request.method, route, status).inc()
    REQUEST_DURATION.labels(request.method, route, status).observe(duration)
    INFLIGHT_REQUESTS.dec()
    return response


@app.errorhandler(Exception)
def handle_exception(exc):
    ERRORS_TOTAL.labels(type="unhandled_exception").inc()
    logger.exception("Unhandled exception: %s", exc)
    return jsonify({"error": "internal_server_error"}), 500


@app.get("/")
def index():
    return jsonify(
        {
            "service": "monitoring-lab-app",
            "status": "ok",
            "time": datetime.now(timezone.utc).isoformat(),
        }
    )


@app.get("/health")
def health():
    return jsonify({"status": "ok"})


@app.get("/metrics")
def metrics():
    return Response(generate_latest(), mimetype=CONTENT_TYPE_LATEST)


@app.get("/work")
def work():
    # Synthetic DB latency workload for request + latency dashboards.
    delay_ms = int(request.args.get("db_ms", "25"))
    operation = request.args.get("op", "select")
    with DB_QUERY_LATENCY.labels(operation=operation).time():
        time.sleep(max(delay_ms, 0) / 1000)
    return jsonify({"ok": True, "db_delay_ms": delay_ms, "operation": operation})


@app.get("/error")
def error():
    code = int(request.args.get("code", "500"))
    msg = request.args.get("msg", "synthetic_error")
    ERRORS_TOTAL.labels(type="synthetic_http_error").inc()
    logger.error("APP_ERROR code=%s msg=%s", code, msg)
    return jsonify({"error": msg, "code": code}), code


def _burn_cpu(seconds: int):
    end = time.time() + max(seconds, 1)
    CPU_SPIKE_ACTIVE.set(1)
    try:
        while time.time() < end:
            _ = sum(i * i for i in range(10000))
    finally:
        CPU_SPIKE_ACTIVE.set(0)


@app.post("/simulate/cpu")
def simulate_cpu():
    seconds = int(request.args.get("seconds", "15"))
    workers = int(request.args.get("workers", "2"))
    logger.warning("SIMULATION cpu_spike seconds=%s workers=%s", seconds, workers)
    for _ in range(max(workers, 1)):
        t = threading.Thread(target=_burn_cpu, args=(seconds,), daemon=True)
        t.start()
    return jsonify({"started": True, "type": "cpu_spike", "seconds": seconds, "workers": workers})


@app.post("/simulate/memory")
def simulate_memory():
    mb = int(request.args.get("mb", "256"))
    seconds = int(request.args.get("seconds", "30"))

    def worker():
        global _memory_hold
        MEMORY_SPIKE_ACTIVE.set(1)
        with _spike_lock:
            _memory_hold = [b"X" * (1024 * 1024) for _ in range(max(mb, 1))]
        logger.warning("SIMULATION memory_spike active mb=%s seconds=%s", mb, seconds)
        time.sleep(max(seconds, 1))
        with _spike_lock:
            _memory_hold = []
        MEMORY_SPIKE_ACTIVE.set(0)
        logger.warning("SIMULATION memory_spike cleared")

    threading.Thread(target=worker, daemon=True).start()
    return jsonify({"started": True, "type": "memory_spike", "mb": mb, "seconds": seconds})


@app.post("/simulate/db-latency")
def simulate_db_latency():
    delay_ms = int(request.args.get("delay_ms", "750"))
    repeats = int(request.args.get("repeats", "20"))
    logger.warning("SIMULATION db_latency delay_ms=%s repeats=%s", delay_ms, repeats)
    for _ in range(max(repeats, 1)):
        with DB_QUERY_LATENCY.labels(operation="select").time():
            time.sleep(max(delay_ms, 0) / 1000)
    return jsonify({"done": True, "delay_ms": delay_ms, "repeats": repeats})


@app.post("/simulate/log-anomaly")
def simulate_log_anomaly():
    count = int(request.args.get("count", "10"))
    pattern = request.args.get("pattern", "AUTH_FAILURE_BURST")
    for i in range(max(count, 1)):
        logger.error("ANOMALY pattern=%s seq=%s source=api msg=unexpected burst", pattern, i + 1)
    return jsonify({"done": True, "anomaly_count": count, "pattern": pattern})


if __name__ == "__main__":
    app.run(host="0.0.0.0", port=int(os.getenv("PORT", "8000")))
