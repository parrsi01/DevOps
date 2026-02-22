# Blue/Green Deployment Lab (Docker + Nginx)

Author: Simon Parris  
Date: 2026-02-22

A repeatable local deployment lab that demonstrates blue/green traffic switching, canary routing, health-gated cutovers, rollback, and deployment failure handling using Docker Compose and Nginx.

## What This Lab Covers

- Two app versions (`blue-v1`, `green-v2`)
- Nginx traffic switching (100% blue / 100% green)
- Canary percentage routing (weighted split)
- Health-based switching before cutover
- Rollback workflow
- Data compatibility rollback risk (shared state schema)

## Architecture

```text
Client -> Nginx (port 8088)
           |- weighted upstream -> app_blue  (port 18081 direct debug)
           `- weighted upstream -> app_green (port 18082 direct debug)

Both apps share: ./data/state.json
```

The shared state file is intentional so you can simulate data compatibility failures during rollback.

## Endpoints

Proxy:
- `http://127.0.0.1:8088/` - app response through router
- `http://127.0.0.1:8088/router-status` - current blue/green weights

Blue direct:
- `http://127.0.0.1:18081/`
- `http://127.0.0.1:18081/health`
- `http://127.0.0.1:18081/state`

Green direct:
- `http://127.0.0.1:18082/`
- `http://127.0.0.1:18082/health`
- `http://127.0.0.1:18082/state`

Control endpoints (for simulations):
- `/control/bad?enabled=1|0` - force app to return 500s
- `/control/migrate?schema=1|2` - change shared schema version

## Quick Start

```bash
cd /home/sp/cyber-course/projects/DevOps/projects/blue-green-deployment-lab
./scripts/start.sh
```

Check status:

```bash
./scripts/status.sh
curl -s http://127.0.0.1:8088/router-status
curl -s http://127.0.0.1:8088/
```

Stop/reset:

```bash
./scripts/stop.sh
./scripts/reset.sh
```

## Traffic Switching Commands

100% blue:

```bash
./scripts/switch_blue.sh
```

100% green:

```bash
./scripts/switch_green.sh
```

Canary (example 10% green / 90% blue):

```bash
./scripts/set_canary.sh 10
./scripts/sample_traffic.sh 50
```

Health-based cutover (only switch if target is healthy):

```bash
./scripts/switch_if_healthy.sh green
./scripts/switch_if_healthy.sh blue
```

## Health-Based Switching (How It Works)

- `switch_if_healthy.sh` calls the target app's `/health` endpoint directly (`18081` or `18082`)
- if health returns `200`, it rewrites Nginx routing weights and reloads Nginx
- if health fails, the cutover is aborted and current traffic routing stays in place

This simulates a simple deployment gate before sending production traffic to a new version.

## Rollback Plan (Operational Runbook)

1. Confirm customer impact (errors, unhealthy target, bad responses)
2. Switch traffic back to known-good version (blue)
3. Verify blue health and sample traffic
4. Keep failed version reachable only for debugging (direct port)
5. Capture logs and root cause
6. Decide full rollback vs partial rollback vs forward-fix

Commands:

```bash
./scripts/rollback_to_blue.sh
./scripts/sample_traffic.sh 30
./scripts/logs.sh nginx
./scripts/logs.sh app_green
```

## Simulations (Repeatable)

## 1. Bad Deployment

Description:
- Green deploy is live but returns 500s under real traffic.

Run:

```bash
./scripts/simulate_bad_deployment.sh
```

What happens:
- routes 10% traffic to green
- forces green into bad mode
- sample traffic shows mixed success and `http_500`
- rollback sends 100% back to blue

Debug commands:

```bash
./scripts/logs.sh app_green
curl -i http://127.0.0.1:18082/health
curl -i http://127.0.0.1:8088/
```

Root cause:
- Application regression in the green version (simulated by forced bad mode).

Resolution:
- Roll back traffic to blue (`rollback_to_blue.sh`) and disable forced bad mode after triage.

## 2. Partial Rollback

Description:
- Green is causing issues, but you want to keep some traffic on it for controlled observation while reducing impact.

Run:

```bash
./scripts/simulate_partial_rollback.sh
```

What happens:
- sends 100% to green
- forces green failure
- reduces green to 20% (partial rollback / controlled canary)
- then fully rolls back to blue

Reasoning goal:
- Decide when partial rollback is acceptable vs too risky.

## 3. Data Compatibility Issue (Rollback Trap)

Description:
- Green upgrades shared data schema to `v2`; blue only supports schema `v1`.
- Rolling back traffic to blue causes blue health and requests to fail.

Run:

```bash
./scripts/simulate_data_compatibility.sh
```

What happens:
- cutover to green
- green migrates schema to `2`
- rollback to blue happens
- blue returns `schema_incompatible` (500)
- forward-fix by switching back to green

Debug commands:

```bash
curl -s http://127.0.0.1:18081/state
curl -i http://127.0.0.1:18081/health
curl -s http://127.0.0.1:18082/state
./scripts/logs.sh app_blue
./scripts/logs.sh app_green
```

Root cause:
- Backward-incompatible data migration without a rollback-safe migration strategy.

Resolution options:
- Forward-fix on green and keep traffic on green
- Run a compatible downgrade migration (lab supports `green /control/migrate?schema=1` for recovery practice)
- Implement expand/contract schema migration pattern for real systems

## Nginx Canary Percentage Routing Notes

This lab uses weighted upstream routing in Nginx:
- `set_canary.sh 10` means approximately `10%` green / `90%` blue over many requests
- short samples may not be exact because routing distribution is statistical

Verify distribution:

```bash
./scripts/set_canary.sh 25
./scripts/sample_traffic.sh 200
```

## Logs and Observability (Local)

Tail all logs:

```bash
./scripts/logs.sh
```

Tail router only:

```bash
./scripts/logs.sh nginx
```

Inspect current route weights:

```bash
curl -s http://127.0.0.1:8088/router-status
```

## Troubleshooting

1. `docker compose up` fails
   - Check Docker daemon health: `docker info`
   - Check host networking/iptables support for Docker bridge networks
2. `switch_if_healthy.sh` aborts
   - Test direct app health on `18081` or `18082`
   - Inspect app logs
3. `sample_traffic.sh` shows only one version during canary
   - Increase sample size (`200+` requests)
   - Verify `router-status`
4. Blue rollback fails after green deploy
   - Check shared schema version in `/state`
   - This is likely the intentional data compatibility scenario

## Tradeoffs: Blue/Green vs Canary vs Rolling Update

## Blue/Green

Pros:
- Fast cutover and fast rollback (traffic switch)
- Clear separation between old and new versions
- Easy to validate new version before cutover

Cons:
- Double capacity cost during deployment
- Data migrations can break rollback if not backward compatible
- Requires load balancer / router control

Best when:
- You need low-downtime deploys and fast rollback with predictable traffic switching.

## Canary

Pros:
- Limits blast radius by sending small % first
- Good for validating behavior under real traffic
- Supports gradual confidence-based rollout

Cons:
- More operational complexity (metrics, routing, policy)
- Harder debugging with mixed traffic and versions
- Requires strong observability to judge rollout safely

Best when:
- You need risk-reduced production validation and have good monitoring/alerting.

## Rolling Update

Pros:
- Simpler in orchestrators (Kubernetes/Swarm/ECS)
- Efficient resource usage (no full duplicate stack)
- No external router scripting required in many platforms

Cons:
- Mixed versions during rollout by default
- Rollback can be slower than traffic switch
- Stateful/data compatibility issues still apply

Best when:
- Platform-native rolling update support is strong and app/database compatibility is well managed.

## Validation Status (This VM)

What was validated in Codex for this module:
- `bash -n projects/blue-green-deployment-lab/scripts/*.sh` (passed)
- `docker compose -f compose.yaml config` (passed)
- Docker image build started successfully via `./scripts/start.sh`

Runtime note:
- Full container startup was blocked on this VM by a host Docker daemon bridge networking issue (`iptables` chain `DOCKER-ISOLATION-STAGE-2` missing), not by lab syntax/config.
