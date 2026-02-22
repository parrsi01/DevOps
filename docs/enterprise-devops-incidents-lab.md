# Enterprise DevOps Incident Simulation Lab (15 Scenarios)

## Enterprise Program Standard

This module is part of a professional infrastructure training program (not a hobby lab).

Training expectations for this module:
- production-grade design and operational assumptions (multi-AZ/region, identity, logging, recovery)
- security controls and least-privilege decisions are part of the exercise, not optional add-ons
- audit awareness: change traceability, approvals, evidence, and rollback records should be captured
- failure domain analysis must be included (process, host/node, AZ/region, dependency, control plane)
- examples are learning-safe but mapped to enterprise patterns; avoid localhost-only reasoning during analysis
- exercises are repeatable without AI by following the documented commands, checklists, and runbooks

Realistic enterprise-style incidents that require reasoning across application, container/orchestrator, OS, network, CI/CD, and platform layers.

Use these as ticket-style drills.

## How To Use This Lab

1. Read the scenario description.
2. Start with the symptom (user-facing behavior).
3. Correlate logs + metrics.
4. Identify the cross-layer dependency causing the failure.
5. Apply the fix.
6. Record a preventive action.

## Cross-Layer Debugging Workflow (Use For Every Scenario)

1. Confirm the user impact (error rate, latency, outage scope).
2. Check recent changes (deployments, config, secrets, infra changes, CI pipeline runs).
3. Correlate across layers:
   - app logs
   - container/pod status
   - host metrics
   - network/LB behavior
   - DB/cache/dependency metrics
4. Verify configuration source of truth (Git, IaC, Helm values, env vars).
5. Roll forward or roll back safely.
6. Add guardrails (alerts, tests, validation, policy).

## 1. DB Connection Pool Exhaustion

### Description
API latency spikes and requests start failing during peak traffic after a new feature increases DB query concurrency.

### Logs
```text
api ERROR db.pool Timeout acquiring connection after 30000ms
api WARN request_id=8f2a route=/checkout status=500 err=db_timeout
postgres LOG could not receive data from client: Connection reset by peer
```

### Metrics
- App `p95` latency jumps from `120ms` to `4.8s`
- `5xx` error rate rises to `18%`
- DB active connections pinned at pool max (`100`)
- CPU moderate (not saturated), DB wait events increase

### Root Cause
Application connection pool size and request concurrency were increased, but connections were not released properly in a new code path during retries.

### Resolution
- Patch connection leak in retry path (`defer/close` missing)
- Reduce worker concurrency temporarily
- Restart app instances to free stuck pool usage

### Preventive Action
- Add pool usage dashboard + alert (`pool_in_use`, acquisition timeout)
- Add load tests covering retry/error paths
- Add code review checklist for connection lifecycle handling

## 2. Memory Leak After Deployment

### Description
A new release appears healthy at first, then pods restart after 20-40 minutes under steady load.

### Logs
```text
app WARN cache growth size=48213 keys
kernel: Memory cgroup out of memory: Killed process 3127 (python)
kubelet Warning OOMKilled container=api pod=api-7f9d8d7f5d-krx2g
```

### Metrics
- Container memory working set climbs steadily (stair-step pattern)
- CPU mostly normal
- Restart count increases after deployment timestamp
- Error rate spikes during pod restarts

### Root Cause
In-memory cache introduced in the deployment had no eviction/TTL for a high-cardinality key pattern.

### Resolution
- Roll back deployment
- Patch cache with TTL + max entries
- Add memory limits/requests review before redeploy

### Preventive Action
- Canary deployment with memory trend monitoring
- Heap/profile checks in performance test stage
- SLO alert on restart rate after deploy

## 3. Rolling Update Failure (Readiness Gate Regression)

### Description
Deployment rollout stalls at 50%; old pods terminate, new pods never become ready, causing partial outage.

### Logs
```text
kubelet Readiness probe failed: HTTP probe failed with statuscode: 404
app INFO listening on :8080
app INFO health endpoint moved to /healthz
```

### Metrics
- Ready pod count drops below desired replicas
- Request latency rises due to fewer serving pods
- Error rate increases on overloaded remaining pods
- Cluster CPU/memory healthy (misleadingly normal)

### Root Cause
Application health endpoint changed from `/health` to `/healthz`, but Kubernetes readiness probe config was not updated.

### Resolution
- Patch deployment readiness probe path to `/healthz`
- Pause/resume rollout or redeploy corrected manifest
- Scale up temporarily if needed to recover capacity

### Preventive Action
- Contract test for probe endpoints in CI
- Helm/chart values validation against app config
- Rollout policy requiring canary + readiness verification

## 4. Broken Container Image Tag

### Description
Production deployment references `app:v1.8.4`, but the tag was never published (or overwritten incorrectly).

### Logs
```text
kubelet Failed to pull image "registry.example.com/app:v1.8.4"
kubelet Error: ImagePullBackOff
registry audit WARN manifest unknown tag=v1.8.4 repo=app
```

### Metrics
- New pod count stuck pending / image pull backoff
- Deployment unavailable replicas increase
- No app CPU/memory rise because containers never start
- CI pipeline shows publish stage skipped/failed earlier

### Root Cause
CI release workflow created deployment commit, but image publish job failed; deployment automation still advanced to prod using a non-existent tag.

### Resolution
- Publish the missing image or redeploy with existing immutable digest
- Block rollout until registry artifact exists
- Reconcile deployment reference to digest, not mutable tag

### Preventive Action
- Deploy by image digest only
- CI/CD gate: verify registry manifest exists before deploy
- Promote artifacts between environments instead of rebuilding

## 5. Expired TLS Certificate

### Description
Users get browser/API TLS failures even though app pods and load balancer look healthy.

### Logs
```text
nginx-ingress ERROR SSL_do_handshake() failed (SSL: error:0A000086:SSL routines::certificate verify failed)
client ERROR x509: certificate has expired or is not yet valid
cert-manager Warning CertificateExpired secret=api-tls
```

### Metrics
- HTTPS request volume drops sharply
- TCP connections may still arrive but TLS handshakes fail
- App metrics show lower traffic (looks like app is idle)
- Error budget burn occurs at edge, not app layer

### Root Cause
TLS certificate auto-renewal failed due to DNS challenge misconfiguration; edge continued serving expired cert.

### Resolution
- Renew/reissue certificate manually
- Fix ACME DNS challenge credentials/config
- Reload ingress/load balancer with updated cert

### Preventive Action
- Alert on cert expiry (30d/14d/7d)
- Monitor renewal jobs and cert-manager events
- Run synthetic HTTPS checks from outside cluster

## 6. Misconfigured Environment Variable

### Description
New deployment returns 500s on startup-dependent endpoints; health may still pass.

### Logs
```text
app ERROR invalid REDIS_URL: missing scheme
app WARN feature cache enabled but backend client init failed
app INFO startup complete (degraded mode=true)
```

### Metrics
- Error rate rises only for cache-backed routes
- Startup/health metrics still green
- Latency increases due to fallback path
- Pod count and host metrics normal

### Root Cause
Environment variable `REDIS_URL` changed to `redis:6379` instead of `redis://redis:6379` in deployment values.

### Resolution
- Correct env var in config/Helm values
- Rollout fixed deployment
- Validate route recovery and error rate returns to baseline

### Preventive Action
- Config schema validation at startup (fail fast)
- CI lint for required env formats
- Staging smoke tests for critical route dependencies

## 7. Disk Full Due To Logs

### Description
Application starts failing writes; unrelated services degrade on same node/VM.

### Logs
```text
app ERROR failed to write upload: no space left on device
dockerd WARN failed to rotate log: write /var/lib/docker/containers/...: no space left on device
node kernel EXT4-fs warning: filesystem full
```

### Metrics
- Host disk usage hits `100%`
- App error rate spikes (write-heavy routes first)
- Log ingestion may drop or become delayed
- CPU/memory remain normal

### Root Cause
Container logs were using unbounded `json-file` logging without rotation; verbose debug logging after incident filled disk.

### Resolution
- Free space (prune old logs / compress / rotate)
- Enable log rotation (`max-size`, `max-file`) or centralized logging
- Reduce debug log volume

### Preventive Action
- Disk usage alerts on host + `/var/lib/docker`
- Standard logging driver defaults with rotation
- Temporary debug logging TTL policy

## 8. CI Pipeline Deploying Wrong Branch

### Description
Production shows unreviewed feature behavior; deployment reports success but commit does not match expected release.

### Logs
```text
github-actions INFO workflow=deploy-prod ref=refs/heads/feature/payment-retry
deploy-bot INFO applying image=ghcr.io/org/app:sha-9f1a2c
app INFO version=feature-payment-retry-9f1a2c
```

### Metrics
- Traffic/error patterns change immediately after deploy
- No infrastructure alarms (deployment itself succeeded)
- GitHub Actions logs show manual dispatch/branch mismatch

### Root Cause
Deploy workflow allowed `workflow_dispatch` from arbitrary branch and used `${{ github.sha }}` without branch protection or environment approvals.

### Resolution
- Roll back to last approved prod image digest
- Lock deploy workflow to `main` tags or protected release branch
- Require environment approval for production deployment

### Preventive Action
- Branch protection + environment protection rules
- Deploy metadata emitted in app startup/version endpoint
- Policy check in CI: prod deploy only from approved refs

## 9. DNS Resolver Degradation Causing Intermittent 502s

### Description
App intermittently fails calls to an upstream API; retries sometimes succeed.

### Logs
```text
app ERROR upstream lookup failed host=payments.internal err=i/o timeout
core-dns ERROR plugin/errors: read udp ... i/o timeout
ingress WARN upstream prematurely closed connection
```

### Metrics
- Intermittent latency spikes and 502s
- App CPU low, memory stable
- DNS request latency / error rate spikes in cluster DNS metrics
- Upstream service itself appears healthy

### Root Cause
Cluster DNS pods were CPU-throttled after noisy-neighbor workload scheduling, causing slow/failed name resolution.

### Resolution
- Increase DNS pod resources / replicas
- Move noisy workload or adjust node/pod resource requests/limits
- Temporarily cache/resuse upstream connections in app

### Preventive Action
- DNS SLI dashboards (latency/error rate)
- Resource reservations for critical platform services
- App-side connection reuse and sensible retry/backoff

## 10. Secret Rotation Broke DB Authentication

### Description
After secret rotation, some pods work and some fail DB auth; rolling restarts worsen the outage.

### Logs
```text
api ERROR pq: password authentication failed for user app_user
external-secrets INFO synced secret db-creds revision=2026-02-22T15:00Z
postgres LOG FATAL: password authentication failed for user "app_user"
```

### Metrics
- Error rate increases as old pods are replaced
- DB connection attempts spike
- Login/auth failures rise on DB metrics/logs
- Deployment rollout correlates with incident start

### Root Cause
Secret was rotated in vault and synced to Kubernetes, but DB user password was not updated successfully (rotation partially failed). New pods used new secret; DB still accepted old password.

### Resolution
- Complete/redo DB credential rotation transactionally
- Pause rollout until application and DB credentials are aligned
- Restart pods only after end-to-end auth verification

### Preventive Action
- Rotation runbook with verification step (app + DB)
- Dual-credential rotation pattern when possible
- Alert on auth failure spike post-secret-sync events

## 11. Load Balancer Health Check Misconfiguration After Path Rewrite Change

### Description
External traffic drops to near-zero after ingress change, while pods are healthy internally.

### Logs
```text
lb-health WARN target unhealthy reason=HTTP_301
ingress INFO rewrite / -> /app
app INFO GET /health 200
```

### Metrics
- External request rate drops sharply
- Internal pod metrics show low/no traffic, low errors
- LB unhealthy target count rises to all targets

### Root Cause
Load balancer health check expected `200` on `/`, but new ingress rule redirected `/` to `/app` with `301`. Targets were marked unhealthy and removed.

### Resolution
- Point LB health check to `/health`
- Or change health check success matcher to include expected redirect (if appropriate)
- Confirm targets return to healthy before ending incident

### Preventive Action
- Health-check contract docs between app and platform teams
- Synthetic external health checks after ingress/LB changes
- Staged rollout for edge config changes

## 12. Time Drift Causing JWT/OAuth Failures

### Description
Authentication failures spike across services; restarts do not help. Symptoms appear random across nodes.

### Logs
```text
api ERROR jwt validation failed: token used before issued (iat in future)
auth-service WARN clock skew detected node=worker-03 skew=187s
chronyd ERROR Can't synchronise: no selectable sources
```

### Metrics
- 401/403 rate spikes
- App CPU/memory normal
- NTP/chrony sync status red on affected nodes
- Authentication latency may increase due to retries

### Root Cause
One node pool lost NTP sync after network ACL change blocked outbound NTP; clock skew broke JWT validation windows.

### Resolution
- Restore NTP access / fix chrony config
- Re-sync affected nodes (or cordon/drain/replace)
- Reduce auth retries to prevent cascading load during recovery

### Preventive Action
- Node time-sync monitoring and alerts
- Network policy tests for critical infra services (NTP/DNS)
- JWT clock-skew tolerance policy (within secure bounds)

## 13. Redis Cache Saturation Causing API Latency and DB Load Surge

### Description
API latency and DB CPU rise simultaneously; cache hit ratio collapses after a marketing campaign traffic spike.

### Logs
```text
api WARN redis timeout op=GET key=user:profile:...
redis-server WARNING maxclients reached
postgres LOG duration: 842 ms  statement: SELECT ...
```

### Metrics
- Redis latency + connections spike
- Cache hit ratio drops
- DB QPS and CPU rise as cache misses flood DB
- API p95 latency and error rate climb together

### Root Cause
Redis instance hit `maxclients` and connection pooling was misconfigured; cache failures caused traffic to fall through to the DB, amplifying load.

### Resolution
- Increase Redis capacity / connections and tune pool settings
- Enable circuit breaker / fallback protection
- Throttle heavy callers if needed during recovery

### Preventive Action
- Cache hit ratio + Redis saturation dashboards/alerts
- Load tests including burst scenarios
- Bulkhead limits between cache and DB tiers

## 14. Wrong Feature Flag Default in Config Service (Payment Path Disabled)

### Description
Payment API starts rejecting transactions after config rollout, but application deploy hash is unchanged.

### Logs
```text
config-service INFO published config version=2026.02.22.4
api ERROR payment flow disabled by feature flag PAYMENTS_V2_ENABLED=false
frontend WARN checkout returned 503 feature_disabled
```

### Metrics
- Payment success rate drops to near-zero
- General site traffic normal
- App version/restart metrics unchanged
- Config service publish event timestamp matches incident onset

### Root Cause
Config service change flipped a default feature flag for production tenant scope due to missing environment override.

### Resolution
- Roll back config version / restore correct tenant-scoped flag
- Verify payment path with synthetic transaction
- Audit config diff for other unintended changes

### Preventive Action
- Config changes treated like deploys (review + approval)
- Per-environment/tenant validation rules
- Synthetic business-transaction monitoring

## 15. Backend Failure in Terraform State Storage During Emergency Change

### Description
Ops team attempts emergency Terraform apply during incident, but Terraform cannot initialize backend/state, delaying remediation.

### Logs
```text
terraform init
Error: Failed to configure the backend "s3"
403 Forbidden: AccessDenied on state bucket
ci-runner ERROR terraform plan failed backend init
```

### Metrics
- Incident duration increases (MTTR impact)
- No infra recovery changes applied
- IAM auth failures spike in audit logs
- CI deploy jobs fail at init/plan stage

### Root Cause
State backend IAM role lost `s3:GetObject/PutObject` (or equivalent) after policy hardening change. Terraform automation could not read/write remote state.

### Resolution
- Restore minimal required backend permissions
- Re-run `terraform init -reconfigure`
- Validate state lock/unlock behavior before apply

### Preventive Action
- Separate backend access policy tests in CI
- Break-glass documented role for state backend access
- Periodic dry-run validation of IaC pipelines against production backends

## How To Interpret Logs + Metrics Together (Reasoning Guidance)

- Logs explain *what failed* at a component level.
- Metrics explain *how widespread* and *how severe* the failure is.
- Deployment/config/audit history explains *what changed*.
- You need all three to avoid false fixes.

Examples:

- App `500`s + DB pool saturation metrics -> likely dependency pressure, not just app bug
- App healthy but edge TLS handshake failures -> certificate/ingress layer incident
- Pods healthy but external traffic zero -> LB/health check/routing issue
- Normal app metrics but bad business outcomes -> feature flag/config rollout issue

## SLI/SLO Framing For Incident Triage (Optional but Recommended)

Use SLIs to quantify impact and prioritize response:

- Availability SLI: successful request ratio (e.g., non-5xx responses)
- Latency SLI: p95/p99 request latency
- Freshness/Queue SLI: consumer lag or job completion delay
- Correctness SLI: business success rate (e.g., payment success)

Translate to SLOs:

- `99.9%` availability over 30 days
- `p95 < 300ms` for checkout API over 7 days
- `payment success rate > 99.5%` over 24 hours

During incidents, ask:

1. Which SLI is burning fastest?
2. Which layer owns the first abnormal signal?
3. What changed just before SLI degradation?
