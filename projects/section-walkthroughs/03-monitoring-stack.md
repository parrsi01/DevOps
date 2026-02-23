# Section 3 - Monitoring Stack Lab

Source docs:

- `docs/monitoring-stack-lab.md`
- `projects/monitoring-stack-lab/README.md`

## What Type Of Software Engineering This Is

Observability engineering and production operations telemetry analysis.

## Definitions

- `metric`: numeric measurement over time (CPU, latency, error rate).
- `dashboard`: visual view of multiple metrics.
- `log`: timestamped event message from an app/system.
- `Prometheus`: metrics collection/query system.
- `Grafana`: dashboard UI for metrics/logs.
- `Loki`: log aggregation/query system.

## Concepts And Theme

Translate user symptoms into measurable signals before choosing a fix.

## 1. Step 1 - Read the lab and understand exposed services

```bash
cd /home/sp/cyber-course/projects/DevOps
sed -n '1,180p' projects/monitoring-stack-lab/README.md
```

What you are doing: confirming ports/endpoints (app, Prometheus, Grafana, Loki) so you know where to verify the stack.

## 2. Step 2 - Start the stack and smoke test it

```bash
cd /home/sp/cyber-course/projects/DevOps/projects/monitoring-stack-lab
./scripts/start.sh
./scripts/smoke_test.sh
docker compose ps
```

What you are doing: bringing up the observability stack and verifying the containers/services are up before generating load.

## 3. Step 3 - Generate baseline traffic

```bash
./scripts/generate_traffic.sh http://127.0.0.1:8000 60 12 20
curl -s http://127.0.0.1:8000/health
docker compose logs app --tail=50
```

What you are doing: creating normal traffic so dashboards/logs have baseline data to compare against later spikes.

## 4. Step 4 - Run one simulation and observe signal changes

```bash
./scripts/simulate_cpu_spike.sh http://127.0.0.1:8000 20 2
./scripts/generate_traffic.sh http://127.0.0.1:8000 30 0 25
docker compose logs app --tail=80
```

What you are doing: forcing a CPU anomaly and confirming the app still serves traffic while metrics/logs reflect the spike.

## 5. Step 5 - Stop and reset the lab

```bash
./scripts/stop.sh
./scripts/reset.sh
```

What you are doing: shutting down the stack and removing volumes/logs so the next practice run starts clean.

## Done Check

You can point to one metric/log change and explain what real behavior caused it.
