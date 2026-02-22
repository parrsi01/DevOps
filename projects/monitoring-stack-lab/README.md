# Monitoring Stack Lab (Prometheus + Grafana + Loki)

Production-style monitoring lab with:

- `Prometheus` (metrics collection)
- `Grafana` (dashboards)
- `Loki` + `Promtail` (logs)
- `cAdvisor` (container metrics)
- `node-exporter` (system metrics)
- instrumented app (`/metrics`, synthetic load/failure endpoints)

## What Is Exposed

- App: `http://127.0.0.1:8000`
- App health: `http://127.0.0.1:8000/health`
- App metrics endpoint: `http://127.0.0.1:8000/metrics`
- Prometheus UI: `http://127.0.0.1:9090`
- Grafana UI: `http://127.0.0.1:3000` (`admin` / `admin`)
- Loki API: `http://127.0.0.1:3100`
- cAdvisor metrics/UI: `http://127.0.0.1:8082`
- node-exporter metrics: `http://127.0.0.1:9100/metrics`

## Dashboards (Provisioned Automatically)

- `CPU Dashboard`
- `Memory Dashboard`
- `Request Rate Dashboard`
- `Error Rate Dashboard` (includes Loki anomaly views)

## Quick Start

```bash
cd projects/monitoring-stack-lab
./scripts/start.sh
```

Wait ~30-60 seconds for exporters + dashboards to populate, then open Grafana.

## Stop / Reset

```bash
./scripts/stop.sh
./scripts/reset.sh   # removes volumes and local logs
```

## Generate Baseline Traffic

```bash
./scripts/generate_traffic.sh http://127.0.0.1:8000 60 12 20
```

Arguments:

1. `base_url` (default `http://127.0.0.1:8000`)
2. `duration_sec` (default `60`)
3. `error_every` (default `10`)
4. `db_ms` (default `25`)

## Simulations (Repeatable)

### 1. Memory Spike

```bash
./scripts/simulate_memory_spike.sh http://127.0.0.1:8000 512 30
```

Expected signals:

- `Memory Dashboard` -> app container working set rises sharply
- `app_memory_spike_active` toggles to `1`
- host memory used % may rise (depends on host size)

### 2. CPU Spike

```bash
./scripts/simulate_cpu_spike.sh http://127.0.0.1:8000 20 2
```

Expected signals:

- `CPU Dashboard` -> app container CPU rises
- `app_cpu_spike_active` toggles to `1`
- host CPU may rise if the VM has fewer cores

### 3. DB Latency Spike (Simulated)

```bash
./scripts/simulate_db_latency.sh http://127.0.0.1:8000 900 20
./scripts/generate_traffic.sh http://127.0.0.1:8000 45 0 900
```

Expected signals:

- `Request Rate Dashboard` -> `DB P95 Latency (ms)` increases
- `HTTP P95 Latency (ms)` often increases too
- request rate may drop if latency is high enough (work takes longer)

### 4. Log Anomaly

```bash
./scripts/simulate_log_anomaly.sh http://127.0.0.1:8000 25 AUTH_FAILURE_BURST
```

Expected signals:

- `Error Rate Dashboard` -> `Log Anomaly Rate (Loki)` rises
- `Anomaly Logs` panel shows `ANOMALY pattern=...`

### 5. Error Rate Spike (HTTP 5xx)

```bash
for i in $(seq 1 30); do curl -s http://127.0.0.1:8000/error?code=500 >/dev/null; done
./scripts/generate_traffic.sh http://127.0.0.1:8000 30 3 25
```

Expected signals:

- `Error Rate Dashboard` -> `5xx Error Rate` rises
- `Error Percentage (5m)` rises
- logs include `APP_ERROR` entries

## How To Interpret Metrics (What Good/Bad Looks Like)

## CPU Dashboard

- Host CPU % high + app container CPU high:
  - app likely causing host saturation
- Host CPU high + app container CPU low:
  - another process/container is the problem
- App CPU cores rising during CPU simulation is expected
- Sustained high CPU with rising latency/error rate is an incident signal

## Memory Dashboard

- App container working set rising is usually the best first container-memory signal
- Host memory used % rising alone is not always bad (Linux cache uses RAM)
- Look for correlation:
  - memory spike -> OOM/restarts -> errors -> latency
- If memory falls after simulation ends, behavior is likely transient, not a leak

## Request Rate Dashboard

- Request rate (`req/s`) tells you throughput
- If request rate drops while traffic input is constant, check latency and errors
- `HTTP P95 Latency` is more operationally useful than average latency
- `DB P95 Latency` rising before HTTP latency often means backend dependency slowdown

## Error Rate Dashboard

- `5xx req/s` shows the absolute error volume
- `Error %` shows impact relative to total traffic
- Low traffic can make `Error %` look extreme (e.g., 1 error in 2 requests = 50%)
- Loki anomaly spikes can indicate security/noise issues before request metrics degrade

## Debug Walkthrough (Operator Flow)

1. Confirm the symptom in Grafana (`CPU`, `Memory`, `Requests`, `Errors`).
2. Check if the app is healthy:
   ```bash
   curl -s http://127.0.0.1:8000/health
   ```
3. Confirm app metrics export:
   ```bash
   curl -s http://127.0.0.1:8000/metrics | head
   ```
4. Verify Prometheus scrape targets:
   - Open `http://127.0.0.1:9090/targets`
   - All targets should be `UP`
5. Inspect logs:
   - Grafana `Error Rate Dashboard` -> `Anomaly Logs`
   - Or query in Loki Explore: `{job="app"}`
6. Check container status:
   ```bash
   docker compose ps
   docker compose logs app --tail=100
   ```
7. Correlate signals (metrics + logs + time window) before making changes.

## SLI / SLO (Plain-English)

### SLI (Service Level Indicator)
A measurable signal that represents user experience or service behavior.

Common SLIs in this lab:

- Availability SLI: fraction of requests that are not `5xx`
- Latency SLI: `p95` HTTP latency (from `app_http_request_duration_seconds`)
- Error SLI: `5xx` rate or error percentage
- Dependency latency SLI: `p95` DB latency (simulated)

### SLO (Service Level Objective)
A target for an SLI over a time window.

Examples (production-style):

- Availability SLO: `99.9%` successful requests over 30 days
- Latency SLO: `p95 < 300ms` for `/work` over 7 days
- Error Rate SLO: `5xx error % < 1%` over 7 days

### Why SLI/SLO matters

- Metrics become actionable only when tied to targets
- Helps decide when an issue is noise vs. real customer impact
- Supports alerting and incident priorities (burn-rate alerting later)

## Useful Prometheus Queries (Cheat Sheet)

Request rate:

```promql
sum(rate(app_http_requests_total{route!="/metrics"}[1m]))
```

5xx error percentage (5m):

```promql
100 * sum(rate(app_http_requests_total{status=~"5..",route!="/metrics"}[5m]))
/ clamp_min(sum(rate(app_http_requests_total{route!="/metrics"}[5m])), 0.001)
```

HTTP p95 latency (ms):

```promql
histogram_quantile(0.95, sum by (le) (rate(app_http_request_duration_seconds_bucket{route!="/metrics"}[5m]))) * 1000
```

DB p95 latency (ms):

```promql
histogram_quantile(0.95, sum by (le) (rate(app_db_query_latency_seconds_bucket[5m]))) * 1000
```

Host CPU used %:

```promql
100 * (1 - avg(rate(node_cpu_seconds_total{job="node-exporter",mode="idle"}[5m])))
```

App container memory working set:

```promql
container_memory_working_set_bytes{job="cadvisor",container_label_com_docker_compose_service="app",image!=""}
```

Loki anomaly count per minute:

```logql
sum(count_over_time({job="app"} |= "ANOMALY" [1m]))
```
