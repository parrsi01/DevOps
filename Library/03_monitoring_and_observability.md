# Monitoring and Observability

---

> **Field** — DevOps / Observability Engineering
> **Scope** — Metrics, logs, dashboards, and alerting concepts from the monitoring stack lab

---

## Overview

Observability is evidence generation. Without it,
debugging is guesswork. This section covers the
three pillars of observability (metrics, logs,
traces) and the tools used in this repository
to collect, visualize, and alert on system behavior.

---

## Definitions

### `Metric`

**Definition.**
A numeric measurement collected over time. Metrics
represent quantities like CPU percentage, requests
per second, error rate, or memory usage.

**Context.**
Metrics answer the question "how much?" or "how
often?" They are the fastest way to detect changes
in system behavior and are the foundation for
alerts and SLOs.

**Example.**
```
http_requests_total{status="500"} 42
# a counter metric tracking 500-status responses
```

---

### `Log`

**Definition.**
A timestamped text record of an event. Logs capture
what happened, when, and often include error
messages, stack traces, or request details.

**Context.**
Logs answer the question "what exactly happened?"
They provide the detail that metrics cannot.
Structured logs (JSON format) are easier to search
and filter than plain text.

**Example.**
```
2026-02-23T10:15:30Z ERROR database connection
refused: host=db port=5432
```

---

### `Dashboard`

**Definition.**
A visual page of graphs, panels, and indicators
that display system metrics and status in real
time. Dashboards are built in tools like Grafana.

**Context.**
Dashboards convert raw numbers into patterns you
can see. A well-designed dashboard answers "is the
system healthy right now?" at a glance.

**Example.**
A Grafana dashboard with panels for:
- Request rate (requests/second)
- Error rate (% of 5xx responses)
- Latency (p50, p95, p99)
- CPU and memory usage

---

### `Alert`

**Definition.**
A rule that triggers a notification when a
condition is met. Alerts fire when metrics cross
a threshold, like error rate exceeding 5% or
disk usage exceeding 90%.

**Context.**
Good alerts are actionable. They tell you something
needs attention. Bad alerts fire too often (alert
fatigue) or not at all (blind spots).

**Example.**
```yaml
alert: HighErrorRate
expr: rate(http_errors_total[5m]) > 0.05
for: 5m
labels:
  severity: warning
```

---

### `Time Series`

**Definition.**
A sequence of data points collected at regular
time intervals. Most monitoring data is stored
as time series: a metric name, labels, and
timestamped values.

**Context.**
Time series databases like Prometheus are optimized
for storing and querying this type of data. Each
metric you collect becomes a time series.

**Example.**
```
cpu_usage{host="web-1"} @ 10:00 = 45%
cpu_usage{host="web-1"} @ 10:15 = 52%
cpu_usage{host="web-1"} @ 10:30 = 48%
```

---

### `Prometheus`

**Definition.**
An open-source monitoring system that collects
metrics from targets by scraping HTTP endpoints
at regular intervals. It stores metrics as time
series and supports a query language called PromQL.

**Context.**
Prometheus is the metrics backbone in this
repository's monitoring stack. It scrapes application
and infrastructure metrics and feeds them to Grafana
for visualization.

**Example.**
```bash
# check if Prometheus is scraping targets
curl http://localhost:9090/api/v1/targets

# PromQL query: request rate over 5 minutes
rate(http_requests_total[5m])
```

---

### `Grafana`

**Definition.**
An open-source dashboard and visualization platform.
Grafana connects to data sources like Prometheus
and Loki to display metrics and logs in customizable
panels.

**Context.**
Grafana is where you look during incidents. It
provides the visual overview of system health
and lets you drill into specific time ranges
and metrics.

**Example.**
```bash
# default local access
open http://127.0.0.1:3000
# login: admin / admin (lab default)
```

---

### `Loki`

**Definition.**
A log aggregation system designed to work with
Grafana. Loki indexes log metadata (labels) rather
than the full log content, making it lightweight
and fast to query.

**Context.**
Loki complements Prometheus. Prometheus tells you
something is wrong (metrics), Loki tells you what
happened (logs). Together they provide complete
observability.

**Example.**
```
# LogQL query in Grafana
{job="nginx"} |= "error"
# shows all nginx logs containing "error"
```

---

### `Scrape`

**Definition.**
The process of Prometheus pulling metrics from a
target's HTTP endpoint at a configured interval.
Each scrape collects the current values of all
exposed metrics.

**Context.**
If a scrape target is down or misconfigured,
Prometheus will show the target as unhealthy and
stop collecting metrics from it. This is a common
cause of "no data" in dashboards.

**Example.**
```yaml
# prometheus.yml scrape config
scrape_configs:
  - job_name: 'my-app'
    static_configs:
      - targets: ['localhost:8080']
    scrape_interval: 15s
```

---

### `Label`

**Definition.**
A key-value pair attached to a metric that adds
dimensions for filtering and grouping. Labels
let you query metrics by host, status code,
endpoint, or any other category.

**Context.**
Labels are powerful but expensive. Too many unique
label combinations (high cardinality) can overload
Prometheus. Use labels for known, bounded sets.

**Example.**
```
http_requests_total{method="GET", status="200"}
http_requests_total{method="POST", status="500"}
# same metric, different label combinations
```

---

### `Observability`

**Definition.**
The ability to understand a system's internal state
by examining its external outputs: metrics, logs,
and traces. A system is observable when you can
answer "why is it broken?" without changing code.

**Context.**
Observability is not just monitoring. Monitoring
tells you when something is wrong. Observability
lets you investigate why.

**Example.**
An observable system exposes: request metrics
(rate, errors, duration), structured logs
(request IDs, error details), and traces
(request flow across services).

---

## Key Commands Summary

```bash
# Start monitoring stack
cd projects/monitoring-stack-lab
./scripts/start.sh

# Check Prometheus targets
curl http://localhost:9090/api/v1/targets

# Access Grafana
open http://127.0.0.1:3000

# Generate test load
curl http://127.0.0.1:8080/endpoint
```

---

## See Also

- [SRE and Incident Management](./08_sre_and_incident_management.md)
- [Containers and Docker](./02_containers_and_docker.md)
- [Universal DevOps Concepts](./00_universal_devops_concepts.md)

---

> **Author** — Simon Parris | DevOps Reference Library
