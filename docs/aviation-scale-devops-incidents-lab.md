# Aviation-Scale DevOps Incident Simulation Lab (20 Scenarios)

Author: Simon Parris  
Date: 2026-02-22

## Enterprise Program Standard

This module is part of a professional infrastructure training program (not a hobby lab).

Training expectations for this module:
- production-grade design and operational assumptions (multi-AZ/region, identity, logging, recovery)
- security controls and least-privilege decisions are part of the exercise, not optional add-ons
- audit awareness: change traceability, approvals, evidence, and rollback records should be captured
- failure domain analysis must be included (process, host/node, AZ/region, dependency, control plane)
- examples are learning-safe but mapped to enterprise patterns; avoid localhost-only reasoning during analysis
- exercises are repeatable without AI by following the documented commands, checklists, and runbooks

## Purpose

This module simulates `20` enterprise-grade DevOps incidents for aviation-scale infrastructure (booking, check-in, flight ops, dispatch, telemetry, and crew systems).

Each scenario requires reasoning across all of these layers:
- Application
- Container
- Orchestration
- Network
- Infrastructure

## Environment Model (Reference)

Assume a multi-region platform with:
- Kubernetes clusters per region (`us-east`, `us-west`, `eu-central`)
- Service mesh / ingress layer
- Managed PostgreSQL + Redis + message bus
- Docker registry for container image pulls
- Terraform-managed infrastructure and CI/CD GitOps pipeline
- Prometheus/Grafana/Loki for observability

## How To Use This Lab

For each scenario:
1. Read the description and symptoms.
2. Correlate the provided logs and metrics across layers.
3. State your hypothesis before reading root cause.
4. Compare your reasoning to the root cause analysis.
5. Record preventive controls in your runbook.

## Cross-Layer Debug Workflow (Reusable)

1. Confirm customer impact and blast radius (which routes/regions/tenants/airports affected)
2. Check application errors and latency first
3. Check container lifecycle/restarts/image/runtime configuration
4. Check orchestration (deployments, pods, nodes, scheduling, rollout history)
5. Check network path (DNS, ingress, LB, east-west traffic, firewall, TLS)
6. Check infrastructure dependencies (DB, Redis, storage, registry, cloud networking)
7. Check recent changes (CI/CD, GitOps sync, Terraform apply, certificate rotation)
8. Stabilize service, then do full RCA and preventive action

## Scenario 1: Kubernetes Node Failure During Flight Ops Peak

Description:
- A worker node in `us-east` fails during morning check-in surge. Critical `flight-ops-api` pods are evicted and rescheduled slowly.

Logs:
- Application:
  ```text
  ERROR request_id=3f1a route=/flight/status upstream timeout after 2.0s
  WARN dependency=redis retry_attempt=3 timeout_ms=200
  ```
- Container (`kubectl logs` from restarted pod):
  ```text
  Starting gunicorn...
  Booting worker with pid: 12
  ```
- Orchestration (`kubectl describe pod` / events):
  ```text
  Warning  NodeNotReady      node/ip-10-0-4-17  Node is not ready
  Warning  FailedScheduling  0/12 nodes are available: 3 Insufficient memory, 2 node(s) were unschedulable.
  ```
- Network / LB:
  ```text
  nginx-ingress upstream timed out (110: Connection timed out) while connecting to upstream
  ```
- Infrastructure:
  ```text
  cloud-init kernel: I/O error, nvme0n1 timeout, controller reset failed
  ```

Metrics:
- `kube_node_status_condition{condition="Ready",status="true"}` drops for one node
- `kube_pod_container_status_restarts_total` spikes for `flight-ops-api`
- `http_request_duration_seconds_p95` rises from `180ms` to `1.8s`
- `node_cpu_seconds_total` on remaining nodes > `90%`

Multi-layer failure interaction:
- Node hardware/storage failure -> node NotReady -> pods evicted -> rescheduling contention -> fewer healthy app endpoints -> ingress timeouts -> user-visible latency/errors.

Layer reasoning:
- Application: timeout/retry noise, not primary fault
- Container: restarts are consequence of rescheduling
- Orchestration: scheduling pressure + node NotReady is key signal
- Network: ingress timeouts reflect backend scarcity
- Infrastructure: underlying node disk/controller failure triggered outage

Root cause analysis:
- Single node failure combined with insufficient spare cluster capacity and weak pod anti-affinity for critical services.

Resolution:
- Cordon/drain failed node, replace node, temporarily scale cluster node group, rebalance replicas.

Prevention measures:
- Reserve headroom for peak traffic
- Pod anti-affinity / topology spread constraints
- Cluster autoscaler tuned for faster scale-out
- Node health alerting tied to critical workload capacity

## Scenario 2: TLS Certificate Expiry on Passenger API Ingress

Description:
- `passenger-api.company.aero` starts failing TLS handshakes after a missed certificate renewal.

Logs:
- Application:
  ```text
  INFO service healthy on port 8080
  ```
- Container (ingress controller):
  ```text
  W0210 11:54:10 controller.go:1234 Error obtaining SSL certificate: certificate has expired
  ```
- Orchestration:
  ```text
  Normal Sync ingress/passenger-api-ingress Scheduled for sync
  Warning Rejected secret/tls-passenger cert invalid or expired
  ```
- Network (client / edge):
  ```text
  TLS handshake error: remote error: tls: expired certificate
  ```
- Infrastructure (cert manager / ACME DNS challenge):
  ```text
  cert-manager challenge failed: NXDOMAIN for _acme-challenge.passenger-api.company.aero
  ```

Metrics:
- `probe_ssl_earliest_cert_expiry` below `0` (expired)
- `nginx_ingress_controller_requests{status=~"4..|5.."}` spikes
- External synthetic probe availability drops to `0%`

Multi-layer failure interaction:
- DNS challenge misconfiguration prevents renewal -> expired TLS secret -> ingress rejects cert -> clients fail before app traffic reaches container.

Layer reasoning:
- Application: healthy, no app errors
- Container: ingress/controller logs expose cert loading failure
- Orchestration: secret/ingress sync warnings show config application issue
- Network: TLS handshake fails at edge
- Infrastructure: DNS/ACME automation failure caused renewal miss

Root cause analysis:
- Automated cert renewal failed due to DNS record misconfiguration and no pre-expiry alert escalation.

Resolution:
- Fix DNS challenge record path, force certificate re-issue, reload ingress, verify chain and expiry.

Prevention measures:
- 30/14/7/3-day cert expiry alerts
- Renewal smoke tests in non-prod
- Backup certificate rotation runbook and ownership

## Scenario 3: Redis Cache Saturation Causing Booking API Timeouts

Description:
- Booking API latency spikes when Redis max memory is reached and eviction thrashes hot keys.

Logs:
- Application:
  ```text
  WARN cache_get timeout key=fare:search:NYC-LHR request_id=9ac2
  ERROR booking_quote failed dependency=redis elapsed_ms=1500
  ```
- Container (booking-api):
  ```text
  gunicorn worker timeout (pid: 41)
  ```
- Orchestration:
  ```text
  HPA booking-api scaling from 12 to 24 replicas based on CPU 78%
  ```
- Network:
  ```text
  envoy upstream reset reason=connection_failure to redis-service:6379
  ```
- Infrastructure (Redis):
  ```text
  Redis maxmemory reached, evicting keys; rejected_connections increased
  ```

Metrics:
- `redis_memory_used_bytes / redis_memory_max_bytes > 0.98`
- `redis_evicted_keys_total` sharply rising
- `redis_connected_clients` at cap
- `http_request_duration_seconds_p95{service="booking-api"}` 250ms -> 3s
- `http_requests_total{status="5xx"}` increases

Multi-layer failure interaction:
- Cache saturation increases latency -> app threads block -> CPU rises -> HPA scales pods -> more Redis clients/connections -> Redis saturation worsens.

Layer reasoning:
- Application: downstream timeouts and worker timeouts
- Container: worker timeouts indicate blocked requests, not crash cause
- Orchestration: autoscaling amplifies dependency load
- Network: service mesh sees connection failures to Redis
- Infrastructure: Redis memory/client limits are root constraint

Root cause analysis:
- Underprovisioned Redis and missing cache key TTL/cardinality controls triggered saturation; HPA scaling created positive feedback.

Resolution:
- Rate-limit expensive queries, increase Redis capacity, reduce client pool sizes, flush/expire pathological key set, tune HPA signal.

Prevention measures:
- Redis saturation alerts (memory, evictions, rejected connections)
- Cache key design reviews + TTL enforcement
- Backpressure/circuit breaker in app
- HPA on latency + queue depth instead of CPU alone

## Scenario 4: DNS Misconfiguration Breaks Crew Scheduling Service Discovery

Description:
- Crew scheduling service cannot reach `postgres.internal.aero` after DNS zone change.

Logs:
- Application:
  ```text
  ERROR psycopg connect failed: could not translate host name "postgres.internal.aero" to address
  ```
- Container:
  ```text
  /etc/resolv.conf nameserver 10.96.0.10
  ```
- Orchestration:
  ```text
  CoreDNS pods Running; no restarts
  ```
- Network (CoreDNS):
  ```text
  [ERROR] plugin/errors: 2 postgres.internal.aero. A: read udp ... i/o timeout
  ```
- Infrastructure (DNS provider):
  ```text
  Zone import applied; internal.aero NS changed to external-only nameservers
  ```

Metrics:
- `coredns_dns_responses_total{rcode="SERVFAIL"}` spike
- `dns_lookup_failures_total{service="crew-scheduler"}` spike
- `db_connection_failures_total` spike
- App availability falls

Multi-layer failure interaction:
- Infra DNS zone change -> CoreDNS forwarders fail -> app name resolution fails -> DB connections fail -> container healthy but app unavailable.

Layer reasoning:
- Application: host resolution failure is direct symptom
- Container: runtime DNS config points to cluster DNS correctly
- Orchestration: pods are healthy; Kubernetes itself not failing
- Network: DNS resolution path broken
- Infrastructure: authoritative zone / forwarder misconfig is root cause

Root cause analysis:
- Incorrect DNS zone delegation removed internal records from resolution path used by cluster forwarders.

Resolution:
- Restore correct authoritative/forwarding configuration, flush caches, verify `dig` from pods and nodes.

Prevention measures:
- DNS change review with dependency inventory
- Synthetic DNS checks for critical internal FQDNs
- Staged rollout of DNS provider changes

## Scenario 5: Terraform State Corruption During Network ACL Change

Description:
- Terraform apply for regional network ACLs crashes mid-write, leaving state partially corrupted.

Logs:
- Application:
  ```text
  ERROR payment-gateway upstream connect timeout to tokenization-service
  ```
- Container (terraform runner job):
  ```text
  panic: unexpected EOF while decoding state JSON
  ```
- Orchestration (CI runner pod):
  ```text
  Job terraform-apply failed, pod evicted due to node preemption
  ```
- Network:
  ```text
  NACL deny rule matched src=10.24.18.0/24 dst=10.24.30.15:443
  ```
- Infrastructure (state backend / object store):
  ```text
  PUT tfstate/us-east/network.tfstate interrupted connection reset by peer
  ```

Metrics:
- `terraform_apply_failures_total` increments
- Inter-service `tcp_connect_errors_total` spike between subnets
- `5xx` rate on payment APIs increases

Multi-layer failure interaction:
- CI job interruption + backend write failure -> corrupted/partial state -> subsequent apply drift -> incorrect ACL rules persist -> app traffic blocked.

Layer reasoning:
- Application: downstream timeouts expose network impact
- Container: Terraform runner panic shows state decode issue
- Orchestration: CI pod eviction contributed to interrupted apply
- Network: NACL deny counters confirm actual traffic block
- Infrastructure: state backend consistency/locking failure is control-plane root cause

Root cause analysis:
- Non-atomic state update under runner preemption without robust locking/versioning safeguards caused state corruption and incorrect reconciliation.

Resolution:
- Restore state from versioned backup, re-import/refresh resources, re-apply reviewed ACL plan.

Prevention measures:
- Remote backend with locking/versioning mandatory
- Protected CI runners for `apply` jobs
- State backups + checksum validation
- `plan` artifact approval before apply

## Scenario 6: Docker Registry Outage Causes Failed Rollouts

Description:
- Private registry becomes unavailable during a scheduled rollout of `checkin-web`.

Logs:
- Application:
  ```text
  Existing pods healthy; no new app logs from updated version
  ```
- Container runtime (`kubelet` / CRI):
  ```text
  Failed to pull image "registry.aero/checkin-web:2026.02.22-rc1": rpc error: code = Unknown desc = error pinging registry
  ```
- Orchestration:
  ```text
  Warning Failed     Error: ImagePullBackOff
  Warning BackOff    Back-off pulling image
  ```
- Network:
  ```text
  tcp_connect_failed dst=registry.aero:443 timeout
  ```
- Infrastructure (registry service):
  ```text
  object storage backend unavailable: 503 Service Unavailable
  ```

Metrics:
- `kube_pod_container_status_waiting_reason{reason="ImagePullBackOff"}` increases
- `deployment_status_replicas_unavailable` for `checkin-web`
- Registry `5xx` and backend object-store latency spike

Multi-layer failure interaction:
- Registry backend outage prevents image pulls -> rollout stalls in orchestration -> partial capacity reduction if maxUnavailable too high -> user errors if old pods already terminated.

Layer reasoning:
- Application: no new version logs indicates deploy never started
- Container: image pull failure is primary execution blocker
- Orchestration: rollout strategy determines impact severity
- Network: connectivity symptom to registry endpoint
- Infrastructure: registry dependency (object store) outage root cause

Root cause analysis:
- Registry object-storage outage during rollout; deployment policy allowed too much unavailable capacity.

Resolution:
- Pause rollout, restore registry/backend, pre-pull image or use cached digest, resume rollout with safer surge/unavailable settings.

Prevention measures:
- Registry HA + object-store redundancy
- Image pull SLO alerts
- Use immutable digests and pre-stage images before peak windows

## Scenario 7: Monitoring Blind Spot During Partial Outage

Description:
- Alerting does not trigger during `flight-status-api` partial outage because metrics scraping silently failed after relabel config change.

Logs:
- Application:
  ```text
  ERROR dependency=route-cache timeout request_id=1de9
  ```
- Container (Prometheus):
  ```text
  level=warn msg="Error on ingesting samples with different labelset"
  ```
- Orchestration:
  ```text
  ConfigMap prometheus-server updated; rollout completed
  ```
- Network:
  ```text
  scrape connection succeeded, HTTP 200, but job label dropped by relabeling
  ```
- Infrastructure:
  ```text
  None (infra healthy)
  ```

Metrics:
- `up{job="flight-status-api"}` missing (series absent)
- Alert rule evaluates to no data instead of firing
- Grafana panel flatlines
- External synthetic probes show availability drop to `92%`

Multi-layer failure interaction:
- Prometheus config change alters labels -> alert selector no longer matches -> outage occurs but monitoring path is blind -> delayed response.

Layer reasoning:
- Application: real user-impact errors present
- Container: Prometheus warnings point to scrape/label ingestion issue
- Orchestration: config rollout succeeded (wrong config, not failed rollout)
- Network: path to scrape target works, so no transport failure
- Infrastructure: healthy, issue is observability control-plane config

Root cause analysis:
- Metrics relabeling change removed/renamed labels used by SLI and paging alerts; no “missing telemetry” alerts existed.

Resolution:
- Revert Prometheus config, restore alert selectors, validate dashboards and alerts against live targets.

Prevention measures:
- Alert on missing `up`/series for critical services
- Prometheus rule unit tests and config lint in CI
- Synthetic checks independent of metrics stack

## Scenario 8: CI Deploys Wrong Artifact to Production

Description:
- CI pipeline deploys a staging build artifact to production after incorrect branch/tag resolution.

Logs:
- Application:
  ```text
  INFO build_version=2026.02.22-staging.14 environment=prod
  ERROR payments disabled by feature gate STAGING_ONLY_MODE
  ```
- Container:
  ```text
  image=registry.aero/checkin-api:staging-14
  ```
- Orchestration:
  ```text
  Deployment checkin-api rollout triggered by image update to staging-14
  ```
- Network:
  ```text
  Increased 403/feature-gate responses via ingress to /payments/*
  ```
- Infrastructure / CI:
  ```text
  GitHub Actions: resolved artifact from workflow_run.head_branch=staging due to fallback path
  ```

Metrics:
- `http_requests_total{status="403",route=~"/payments.*"}` spike
- Deployment annotation shows unexpected SHA/tag
- Release audit trail mismatches change ticket

Multi-layer failure interaction:
- CI metadata parsing bug -> wrong image tag published/deployed -> orchestration rollout succeeds technically -> app logic misbehaves in prod -> network serves valid but incorrect responses.

Layer reasoning:
- Application: feature gates reveal environment mismatch
- Container: running wrong image tag proves artifact problem
- Orchestration: deployment executed as instructed
- Network: traffic is flowing; issue is correctness, not connectivity
- Infrastructure: CI pipeline logic and artifact registry metadata caused incident

Root cause analysis:
- Pipeline fallback logic selected last successful staging artifact when production tag metadata was missing.

Resolution:
- Roll back to prior production digest, patch CI branch/tag resolution, add deployment attestation checks.

Prevention measures:
- Immutable digest promotion model (dev -> staging -> prod same digest)
- Environment-specific policy checks before deploy
- Manual approval with artifact digest verification

## Scenario 9: Cross-Region Latency Spike on Passenger Search

Description:
- `us-east` app pods begin calling `eu-central` database read replica due to service discovery failover policy bug, increasing latency.

Logs:
- Application:
  ```text
  WARN query latency high replica=eu-central elapsed_ms=780 request_id=ab91
  ```
- Container (sidecar/service mesh):
  ```text
  xDS cluster updated: preferred_locality unset, failover priority changed
  ```
- Orchestration:
  ```text
  mesh-control deployment rolled out config revision 8421
  ```
- Network:
  ```text
  inter-region RTT us-east<->eu-central increased to 145ms; packet loss 1.2%
  ```
- Infrastructure:
  ```text
  WAN provider maintenance in progress on transatlantic path B
  ```

Metrics:
- `http_request_duration_seconds_p95{service="passenger-search"}` 220ms -> 1.4s
- `db_client_queries_total{region="eu-central"}` unexpectedly high from us-east services
- Inter-region egress bytes spike

Multi-layer failure interaction:
- Mesh config changed locality routing -> app sends cross-region DB reads -> WAN maintenance adds RTT/loss -> user latency spikes.

Layer reasoning:
- Application: query latency with remote replica identifier is clue
- Container: sidecar routing config changed behavior
- Orchestration: config rollout timestamp aligns with incident
- Network: inter-region RTT degradation amplifies issue
- Infrastructure: WAN maintenance worsens but did not initiate misroute

Root cause analysis:
- Service mesh locality policy regression disabled local-preference routing for DB read traffic.

Resolution:
- Roll back mesh config, pin local endpoints, fail over only on verified local replica health failure.

Prevention measures:
- Route policy tests in staging with locality assertions
- Alerts on unexpected cross-region dependency traffic
- Change freeze for mesh config during provider maintenance windows

## Scenario 10: Database Deadlock in Ticketing Transactions

Description:
- Ticketing service experiences intermittent 500s due to deadlocks during seat inventory updates.

Logs:
- Application:
  ```text
  ERROR tx failed SQLSTATE=40P01 deadlock detected route=/ticket/confirm flight=AX217
  ```
- Container:
  ```text
  worker retrying transaction attempt=2 jitter_ms=25
  ```
- Orchestration:
  ```text
  Pod CPU elevated but stable; no restarts
  ```
- Network:
  ```text
  db connections healthy, low packet loss
  ```
- Infrastructure (Postgres):
  ```text
  LOG: process 18291 detected deadlock while waiting for ShareLock on transaction 771228
  DETAIL: Process 18291 waits for row lock on seat_inventory ...
  ```

Metrics:
- `db_deadlocks_total` spike
- `http_requests_total{status="500",service="ticketing"}` surge
- `db_lock_wait_seconds_p95` increases
- CPU/memory normal on nodes and pods

Multi-layer failure interaction:
- App concurrency pattern introduces deadlocks -> retries increase DB pressure and response latency -> orchestrator/network remain healthy, making diagnosis app/DB-layer focused.

Layer reasoning:
- Application: SQLSTATE 40P01 is primary clue
- Container: retries show mitigation but also amplification risk
- Orchestration: healthy pods narrow issue away from platform failure
- Network: no connectivity issue confirms DB logic issue
- Infrastructure: DB engine logs confirm deadlock graph

Root cause analysis:
- Deployment introduced lock acquisition order inconsistency across two transaction paths.

Resolution:
- Roll back release or patch transaction ordering, reduce concurrent seat-confirm writes, add idempotent retry with backoff.

Prevention measures:
- Concurrency tests and DB deadlock chaos tests
- Consistent lock ordering design review
- Deadlock alerts with SQL fingerprinting

## Scenario 11: Kafka Consumer Lag Explosion After Partition Rebalance

Description:
- Flight telemetry processors fall behind after node maintenance causes consumer rebalance storm.

Logs:
- Application:
  ```text
  WARN lag exceeded threshold topic=telemetry.ingest partition=42 lag=185000
  ```
- Container:
  ```text
  JVM GC pause 1.2s; consumer heartbeat delayed
  ```
- Orchestration:
  ```text
  Node drain evicted 8 telemetry-worker pods, rescheduled across 2 nodes
  ```
- Network:
  ```text
  broker connection resets during rebalance; retrying metadata fetch
  ```
- Infrastructure:
  ```text
  Kafka broker CPU 95%, request queue time increasing
  ```

Metrics:
- `kafka_consumer_lag` large spike
- `kafka_rebalances_total` spike
- `telemetry_processing_latency_seconds_p99` increases
- Node CPU saturation on destination nodes

Multi-layer failure interaction:
- Node maintenance triggers pod churn -> consumer rebalances -> broker load spikes -> GC/network heartbeat delays -> more rebalances and lag.

Layer reasoning:
- Application: lag alarms indicate throughput deficit
- Container: GC pauses worsen heartbeats
- Orchestration: drain concentrated workload causing imbalance
- Network: broker reconnect churn is secondary amplifier
- Infrastructure: broker saturation + poor partition placement contributes

Root cause analysis:
- Aggressive node drain combined with inadequate PodDisruptionBudget and consumer group tuning caused rebalance cascade.

Resolution:
- Slow drain rate, spread pods, tune consumer session/heartbeat, add broker capacity, drain during low-load windows.

Prevention measures:
- PDBs for telemetry workers
- Rebalance and lag alerts
- Maintenance runbooks with workload-specific drain limits

## Scenario 12: Time Drift Causes JWT Authentication Failures

Description:
- A subset of nodes drift time by >90 seconds, causing JWT validation failures for crew mobile API.

Logs:
- Application:
  ```text
  ERROR jwt validation failed: token used before issued (iat in future)
  ```
- Container:
  ```text
  container time=2026-02-22T19:10:03Z
  ```
- Orchestration:
  ```text
  Failures limited to pods scheduled on nodes ip-10-0-7-31 and ip-10-0-7-32
  ```
- Network:
  ```text
  NTP egress to time source intermittently blocked by firewall update
  ```
- Infrastructure:
  ```text
  chronyd: Source 169.254.169.123 unreachable; clock offset +97.4s
  ```

Metrics:
- `http_requests_total{status="401",reason="jwt_iat"}` spikes on subset pods
- Node time offset metric (node exporter / chrony exporter) > `90s`
- No app CPU/memory anomaly

Multi-layer failure interaction:
- Infra/NTP time sync failure on nodes -> container clocks drift -> app auth rejects valid tokens -> orchestrator pattern shows node affinity of failures.

Layer reasoning:
- Application: auth errors but only for time-based claims
- Container: inherits host clock, no container-specific bug
- Orchestration: failures correlate to specific nodes
- Network: NTP path blocked causes sync issue
- Infrastructure: chrony offset confirms root cause

Root cause analysis:
- Firewall change blocked NTP egress from a subset of nodes, causing clock drift beyond JWT skew tolerance.

Resolution:
- Restore NTP connectivity, force time sync, recycle affected pods, temporarily widen JWT clock skew if approved.

Prevention measures:
- Node time-offset alerting
- Firewall policy tests for NTP dependencies
- Multi-source NTP configuration

## Scenario 13: Kubernetes CNI IP Exhaustion Prevents Pod Scheduling

Description:
- New pods for `ops-dashboard` cannot start in `us-west` due to exhausted pod IPs on node subnet.

Logs:
- Application:
  ```text
  No new app logs; pods never start
  ```
- Container runtime:
  ```text
  failed to create pod sandbox: CNI failed to assign IP address
  ```
- Orchestration:
  ```text
  Warning FailedCreatePodSandBox CNI plugin failed: no IP addresses available in network range
  ```
- Network:
  ```text
  CNI IPAM allocation errors increasing
  ```
- Infrastructure:
  ```text
  VPC subnet 10.42.16.0/24 available IPs: 0
  ```

Metrics:
- `kube_pod_status_phase{phase="Pending"}` spike
- `cni_ipam_allocations_failed_total` spike
- Subnet free IP count `0`

Multi-layer failure interaction:
- Infra subnet depletion -> CNI IP allocation fails -> pod sandbox creation fails -> deployment rollout stalls -> app capacity cannot scale during traffic event.

Layer reasoning:
- Application: absence of logs suggests startup never reached app
- Container: sandbox creation error points below image/app layer
- Orchestration: Pending/FailedCreatePodSandBox events are primary k8s clue
- Network: CNI IPAM failure is direct network layer fault
- Infrastructure: subnet sizing is root capacity issue

Root cause analysis:
- Subnet CIDR too small for node/pod density plus surge rollout strategy.

Resolution:
- Expand subnet / add new node pools in larger CIDR, reduce max pods per node, clean stale ENIs/IP allocations.

Prevention measures:
- IP capacity forecasting and alerts
- Pre-flight checks for surge rollouts
- CIDR sizing standards for peak + failure scenarios

## Scenario 14: Load Balancer Health Check Misconfiguration After Release

Description:
- New release changes app health path from `/health` to `/healthz`, but external LB still checks `/health` and marks targets unhealthy.

Logs:
- Application:
  ```text
  404 GET /health request_id=lb-probe
  ```
- Container:
  ```text
  app healthy; /healthz returns 200
  ```
- Orchestration:
  ```text
  Readiness probes green (using /healthz)
  ```
- Network / LB:
  ```text
  Target group marked unhealthy: Health checks failed with code 404
  ```
- Infrastructure:
  ```text
  LB config not updated in Terraform plan (manual config drift)
  ```

Metrics:
- `target_group_healthy_hosts` drops to `0`
- App pod readiness stays `1`
- External availability `0%`, internal service tests `100%`

Multi-layer failure interaction:
- App path contract changed -> k8s probes updated but external LB config drifted -> pods healthy internally yet no external traffic reaches them.

Layer reasoning:
- Application: 404 on probe path is clue, app otherwise healthy
- Container: runtime is fine
- Orchestration: readiness green isolates issue beyond cluster service path
- Network: LB health checks fail, traffic dropped at edge
- Infrastructure: LB config drift is root configuration gap

Root cause analysis:
- Incomplete release checklist missed external load balancer health-check path update.

Resolution:
- Update LB health path to `/healthz` (via IaC), verify healthy targets, add compatibility redirect temporarily if needed.

Prevention measures:
- Health endpoint contract governance
- End-to-end pre-deploy synthetic checks
- IaC-only LB config changes + drift detection

## Scenario 15: Secret Rotation Breaks Database Authentication

Description:
- DB password rotated in secrets manager, but one namespace secret and deployment were not updated, causing auth failures.

Logs:
- Application:
  ```text
  ERROR db auth failed: password authentication failed for user flight_ops
  ```
- Container:
  ```text
  env DB_PASSWORD loaded from secret flight-ops-db-credentials
  ```
- Orchestration:
  ```text
  secret/flight-ops-db-credentials unchanged in namespace ops-prod
  deployment restarted from automation in other namespaces only
  ```
- Network:
  ```text
  TCP handshake to postgres succeeded
  ```
- Infrastructure:
  ```text
  secrets manager rotation completed version=2026-02-22T18:00Z
  ```

Metrics:
- `db_auth_failures_total{service="flight-ops-api"}` spike
- `postgres_connections_rejected_total` increases
- Network latency normal

Multi-layer failure interaction:
- Infra secret rotation succeeds -> orchestration secret sync incomplete in one namespace -> containers start with stale env secret -> app auth fails while network/db remain reachable.

Layer reasoning:
- Application: auth error specific and clear
- Container: secret injection mechanism worked, but stale value
- Orchestration: namespace-specific secret sync gap is key
- Network: healthy transport rules out connectivity issue
- Infrastructure: rotation success can falsely imply deployment safety

Root cause analysis:
- Secret sync automation targeted subset of namespaces; no post-rotation verification across all prod namespaces.

Resolution:
- Sync secret to affected namespace, restart deployment, validate DB auth and rotation propagation.

Prevention measures:
- Centralized secret sync controller with status reporting
- Rotation rollout checklist and validation job per namespace
- Dual-password rotation window where supported

## Scenario 16: Persistent Volume Latency Spike Triggers Cascading Restarts

Description:
- `baggage-tracking` service backed by persistent volumes experiences storage latency spikes causing request timeouts and liveness probe failures.

Logs:
- Application:
  ```text
  ERROR write event journal timeout elapsed_ms=4100
  ```
- Container:
  ```text
  Liveness probe failed: HTTP probe failed with statuscode: 500
  ```
- Orchestration:
  ```text
  Killing container baggage-tracking due to failed liveness probe
  ```
- Network:
  ```text
  None significant; service network stable
  ```
- Infrastructure (storage):
  ```text
  EBS volume queue depth high; latency p99 220ms -> 1800ms on node i-0f2a...
  ```

Metrics:
- `kube_pod_container_status_restarts_total` rising
- `volume_read_latency_seconds_p99` / `volume_write_latency_seconds_p99` spike
- `http_requests_total{status="5xx"}` spike

Multi-layer failure interaction:
- Storage latency -> app I/O timeouts -> health endpoint degrades -> kube liveness restarts containers -> cold starts increase load and make incident worse.

Layer reasoning:
- Application: I/O timeout indicates dependency latency
- Container: liveness failures are secondary symptom
- Orchestration: restart loop amplifies degradation
- Network: clean path reduces search space
- Infrastructure: storage latency root cause

Root cause analysis:
- Underprovisioned IOPS / noisy-neighbor storage performance degradation combined with aggressive liveness probe thresholds.

Resolution:
- Increase storage performance, relax liveness thresholds temporarily, prefer readiness failure over liveness for dependency slowness.

Prevention measures:
- Storage latency alerts linked to pod restart spikes
- Probe design review (dependency-aware health semantics)
- Workload IOPS sizing for peak write bursts

## Scenario 17: Ingress Rate-Limit Misconfiguration Blocks Internal API Consumers

Description:
- New ingress rate-limit annotation intended for public clients is applied to internal partner gateway path, causing 429s and cascading retries.

Logs:
- Application:
  ```text
  WARN upstream retries high from partner-gateway request_id=6d91
  ```
- Container (ingress):
  ```text
  limiting requests, excess: 24.310 by zone "partner_rl" client: 10.12.8.44
  ```
- Orchestration:
  ```text
  Ingress updated by GitOps sync revision 5f2a1d
  ```
- Network:
  ```text
  East-west traffic surge due to retry storm between partner-gateway and booking-api
  ```
- Infrastructure:
  ```text
  None degraded; infra healthy
  ```

Metrics:
- `nginx_ingress_controller_requests{status="429"}` spike
- `retry_attempts_total{service="partner-gateway"}` spike
- East-west bandwidth and connection count spike

Multi-layer failure interaction:
- Ingress config change -> rate-limit on internal trusted clients -> app retries amplify traffic -> network congestion increases latency and error rate.

Layer reasoning:
- Application: retries reveal downstream throttling and poor backoff
- Container: ingress logs show explicit limiting
- Orchestration: GitOps sync identifies config change origin
- Network: retry storm magnifies blast radius
- Infrastructure: healthy, issue is config and traffic behavior

Root cause analysis:
- Mis-scoped ingress annotation and lack of separate policies for public vs internal traffic.

Resolution:
- Revert ingress annotation, disable aggressive retries, validate path-specific rate-limit configs.

Prevention measures:
- Ingress policy templates with environment/path guards
- Retry budgets and exponential backoff
- Canary config rollout for ingress changes

## Scenario 18: Autoscaler Thrash Causes Cascading Cold Starts

Description:
- HPA for `search-api` scales aggressively up and down due to noisy CPU metrics, causing repeated cold starts and cache misses.

Logs:
- Application:
  ```text
  WARN cache warmup miss ratio=0.92 after pod start
  ```
- Container:
  ```text
  startup completed in 18.4s
  ```
- Orchestration:
  ```text
  HPA search-api scaling from 8->20 then 20->9 within 4m
  ```
- Network:
  ```text
  Spike in calls to cache and profile services during warmup windows
  ```
- Infrastructure:
  ```text
  Node autoscaler adding/removing nodes frequently; image pulls increase disk I/O
  ```

Metrics:
- `hpa_status_desired_replicas` oscillation
- `pod_startup_latency_seconds` spike
- `cache_hit_ratio` drops
- `http_request_duration_seconds_p95` oscillates with HPA events

Multi-layer failure interaction:
- Noisy autoscaling -> pod churn -> cold starts + cache miss storms -> dependency load spikes -> CPU noise worsens -> more scaling thrash.

Layer reasoning:
- Application: cache warmup and cold-start behavior drives latency
- Container: startup time matters in scale decisions
- Orchestration: HPA policy oscillation is direct amplifier
- Network: dependency fan-out spikes during warmups
- Infrastructure: node churn adds pull/start latency

Root cause analysis:
- HPA policy too sensitive (short stabilization windows, CPU-only metric) for bursty workload.

Resolution:
- Add stabilization windows, scale on request rate/latency, pre-warm cache, set min replicas higher.

Prevention measures:
- HPA policy testing with replay traffic
- Scale decisions on business metrics + latency
- Warm pool or pre-provisioned nodes for peak periods

## Scenario 19: Poison Message Causes Worker CrashLoop and Queue Backlog

Description:
- A malformed telemetry message triggers parser panic in worker, causing CrashLoopBackOff and growing queue backlog.

Logs:
- Application:
  ```text
  panic: invalid telemetry frame length=65535 route=ingest-parser
  ```
- Container:
  ```text
  terminated with exit code 2
  ```
- Orchestration:
  ```text
  Warning BackOff Back-off restarting failed container telemetry-worker
  ```
- Network:
  ```text
  Message broker connections healthy; consumers disconnecting/reconnecting
  ```
- Infrastructure:
  ```text
  Queue depth increasing on telemetry.ingest.dlq? no (main queue only)
  ```

Metrics:
- `kube_pod_container_status_waiting_reason{reason="CrashLoopBackOff"}` increases
- `queue_depth{queue="telemetry.ingest"}` spikes
- `consumer_throughput` drops near zero

Multi-layer failure interaction:
- App parser panic on bad payload -> container exits -> orchestrator crash loop -> queue backlog grows -> upstream services slow as buffers fill.

Layer reasoning:
- Application: parser panic is direct failure
- Container: exit code confirms process termination
- Orchestration: CrashLoopBackOff explains capacity collapse
- Network: broker connectivity healthy rules out transport issues
- Infrastructure: queue backlog indicates downstream processing halt

Root cause analysis:
- Missing input validation and poison-message handling; no dead-letter routing for malformed frames.

Resolution:
- Quarantine bad message(s), patch parser with validation, add dead-letter behavior and replay controls.

Prevention measures:
- Schema validation before processing
- DLQ policies and poison-message detection alerts
- Fuzz testing for parsers

## Scenario 20: Feature Flag Service Partial Outage Triggers Fallback Storm

Description:
- Feature flag service in one region becomes partially unavailable; many apps fall back to direct DB reads for flags, overloading shared config database.

Logs:
- Application:
  ```text
  WARN flag fetch timeout source=flag-service falling back to db request_id=21f8
  ERROR config DB timeout during flag fallback elapsed_ms=1200
  ```
- Container:
  ```text
  app threads blocked waiting on config client pool
  ```
- Orchestration:
  ```text
  Multiple services scaling up due to elevated latency; no pod failures initially
  ```
- Network:
  ```text
  Increased east-west calls to flag-service and config-db service endpoints
  ```
- Infrastructure:
  ```text
  config-db CPU 92%, connection pool saturation; storage latency normal
  ```

Metrics:
- `feature_flag_request_timeout_total` spikes
- `config_db_connections_active / max > 0.95`
- `http_request_duration_seconds_p95` increases across multiple services
- `5xx` surge in services using synchronous flag checks

Multi-layer failure interaction:
- Partial flag-service outage -> app fallback logic fans out to shared DB -> DB saturation -> more latency/timeouts -> orchestrator scales services -> connection demand increases further.

Layer reasoning:
- Application: fallback behavior is the amplifier
- Container: thread pools block due to dependency waits
- Orchestration: autoscaling increases connection/cardinality pressure
- Network: east-west dependency calls surge
- Infrastructure: shared config DB becomes bottleneck

Root cause analysis:
- Unsafe fallback design (synchronous DB fallback from many services) turned a partial dependency outage into a cross-service cascade.

Resolution:
- Disable DB fallback for non-critical flags, serve cached defaults, restore flag-service capacity, enforce client timeouts/circuit breakers.

Prevention measures:
- Tiered flags (critical vs non-critical) with local cache defaults
- Circuit breakers and request coalescing
- Dependency failure mode reviews and load tests

## Summary Patterns (What Repeats in Aviation-Scale Incidents)

1. Control-plane success does not guarantee service correctness (CI/CD, GitOps, IaC can deploy the wrong thing correctly)
2. Retry/autoscaling can amplify incidents if dependency limits are ignored
3. Monitoring gaps are incidents too (blind spot = delayed detection)
4. Data/schema compatibility often determines whether rollback is actually safe
5. Network symptoms are often downstream effects of app/orchestration/infra changes

## Practice Exercise (Repeatable)

Use any scenario above and write a mini incident note with:
- `symptom`
- `blast_radius`
- `timeline`
- `hypothesis_1 / hypothesis_2`
- `root_cause`
- `stabilization`
- `prevention`

Store your notes in a dated file under `docs/` and commit them for revision history.
