# Section 8 - SRE Simulation Lab

Source docs:

- `docs/sre-simulation-lab.md`
- `projects/sre-simulation-lab/README.md`

## What Type Of Software Engineering This Is

Site Reliability Engineering (SRE): reliability-focused software engineering using SLIs, SLOs, error budgets, incidents, and postmortems.

## Definitions

- `SLI`: measured service behavior (availability, latency, error rate).
- `SLO`: target for an SLI over a time window.
- `error budget`: allowed unreliability before reliability work must be prioritized.
- `incident`: a service disruption or significant degradation.
- `postmortem`: structured review of what happened and how to prevent repeats.

## Concepts And Theme

Move from raw metrics to operational decisions: what user impact happened, what evidence proves it, and what action is justified.

## 1. Step 1 - Start the dependency monitoring stack and run SRE preflight

```bash
cd /home/sp/cyber-course/projects/DevOps/projects/monitoring-stack-lab
./scripts/start.sh
./scripts/smoke_test.sh
cd ../sre-simulation-lab
./scripts/preflight.sh
```

What you are doing: ensuring the monitoring stack is available, because the SRE lab reads metrics and service health from that stack.

## 2. Step 2 - Read the SRE module and calculate error budgets

```bash
sed -n '1,260p' README.md
./scripts/error_budget_calc.sh 99.9 30
./scripts/error_budget_calc.sh 99.95 30
```

What you are doing: reviewing the reliability concepts and converting SLO targets into usable error-budget numbers.

## 3. Step 3 - Generate a baseline and capture an incident snapshot

```bash
./scripts/simulate_traffic_spike.sh 60 0 20
./scripts/incident_snapshot.sh
```

What you are doing: creating normal-ish load and capturing a baseline evidence snapshot before a failure drill.

## 4. Step 4 - Trigger one incident simulation and collect evidence

```bash
./scripts/simulate_5xx_surge.sh 80
./scripts/incident_snapshot.sh
```

What you are doing: creating an error-rate incident and gathering evidence you can use for impact, timeline, and mitigation decisions.

## 5. Step 5 - Stop the dependency stack when finished

```bash
cd ../monitoring-stack-lab
./scripts/stop.sh
```

What you are doing: shutting down the monitoring dependency after the SRE lab run to avoid leaving background containers running.

## Done Check

You can describe the incident in both ways:

- user-impact story
- metric/SLI story
