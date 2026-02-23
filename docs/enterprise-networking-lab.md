# Enterprise Networking Module (Module 15, Aviation-Grade Infrastructure)

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

## Module Goal

Build a beginner-to-advanced, repeatable enterprise networking training module for aviation-grade environments that covers packet behavior, transport protocols, TLS, load balancing, DNS, NAT, segmentation, firewalls, and cross-layer troubleshooting.

## Learning Path (Beginner -> Advanced -> Operations)

1. Foundations: TCP/UDP, DNS path, NAT, stateful/stateless services
2. Platform networking: L4/L7 load balancers, reverse proxies, firewall patterns, segmentation
3. Transport security: TLS handshake internals and failure diagnosis
4. Performance and reliability: MTU, fragmentation, latency, packet loss, asymmetric routing
5. Enterprise incident response: multi-layer debugging using logs, metrics, packet captures, and change history

## Reference Aviation-Grade Network Architecture (Text Diagram)

```text
                                  +-----------------------------+
                                  | Global Traffic Mgmt / DNS   |
                                  | geo + health + failover     |
                                  +--------------+--------------+
                                                 |
                        +------------------------+------------------------+
                        |                                                 |
                        v                                                 v
          +-------------+-------------+                     +-------------+-------------+
          | Region A Edge (Primary)   |                     | Region B Edge (Secondary) |
          | WAF + DDoS + L7 Ingress   |                     | WAF + DDoS + L7 Ingress   |
          +------+--------------------+                     +------+--------------------+
                 |                                                   |
                 v                                                   v
      +----------+-----------+                           +-----------+----------+
      | L4 Internal LB Tier  |                           | L4 Internal LB Tier  |
      | TCP passthrough apps |                           | TCP passthrough apps |
      +----------+-----------+                           +-----------+----------+
                 |                                                   |
      +----------+---------------------+                 +-----------+-------------------+
      | Kubernetes App Segments        |                 | Kubernetes App Segments      |
      | - DMZ ingress namespace        |                 | - DMZ ingress namespace      |
      | - API namespace                |                 | - API namespace              |
      | - Internal services namespace  |                 | - Internal services namespace|
      | - Data access namespace        |                 | - Data access namespace      |
      +----------+---------------------+                 +-----------+-------------------+
                 |                                                   |
        +--------+--------+                                 +--------+--------+
        | Redis Cache     |                                 | Redis Cache     |
        | (private subnets)|                                | (private subnets)|
        +--------+--------+                                 +--------+--------+
                 |                                                   |
        +--------+-----------------------------------+     +--------+------------------+
        | DB Cluster (writer, multi-AZ)              |<--->| Cross-region replica / DR|
        | private subnets + restricted ports         |     | replication + promotion   |
        +--------------------------------------------+     +---------------------------+

Management / observability plane (separate segments):
- Bastion / VPN / ZTNA access
- Prometheus / Grafana / Loki / SIEM
- CI/CD runners / registry / GitOps controllers
```

## Failure Domains (Networking Lens)

- `L7` application protocol contracts (headers, routes, timeouts)
- `L4` transport behavior (connections, retransmits, TLS passthrough/load balancing)
- Node/host networking (NIC, MTU, conntrack, routing tables)
- Subnet / security policy domain (ACLs, SGs, firewall policies, network policies)
- AZ / region pathing (WAN, transit gateways, DNS failover)
- Control-plane domain (DNS config, LB config, service mesh policy, IaC state)

## 1. Deep TCP vs UDP Behavior

## TCP (reliable, connection-oriented)

Key behaviors:
- 3-way handshake (`SYN`, `SYN-ACK`, `ACK`)
- ordered delivery and retransmissions
- congestion control and flow control (window sizing)
- connection teardown (`FIN`, `RST`)

Enterprise implications:
- Head-of-line blocking can inflate latency under loss
- Poor timeout/retry tuning causes retry storms
- Stateful firewall / conntrack pressure can impact TCP-heavy APIs

Packet capture example (handshake + retransmits):
```bash
sudo tcpdump -ni eth0 'tcp and host api.prod.aero and port 443'
sudo tcpdump -ni eth0 'tcp[tcpflags] & (tcp-syn|tcp-ack) != 0 and host api.prod.aero'
```

What to look for:
- many `SYN` with no `SYN-ACK` -> firewall/LB/path issue
- repeated `[P.]` + retransmits -> packet loss/latency/MTU issue
- `RST` from server or proxy -> app/proxy policy or idle timeout mismatch

## UDP (connectionless, best-effort)

Typical uses:
- DNS queries
- telemetry / metrics (some pipelines)
- QUIC/HTTP3 (UDP transport with reliability in protocol layer)

Enterprise implications:
- loss/reordering handled by application protocol (if at all)
- stateful devices may still track flows, but semantics differ
- rate limiting and amplification risks matter (DNS, reflection attacks)

Packet capture example (DNS/UDP):
```bash
sudo tcpdump -ni eth0 'udp port 53 and (host 10.20.0.10 or host 10.20.0.11)'
```

## 2. TLS Handshake Breakdown (Production View)

## TLS handshake stages (simplified modern TLS 1.2/1.3)

1. `ClientHello`
   - SNI (`api.company.aero`)
   - supported ciphers
   - supported TLS versions
   - ALPN (`h2`, `http/1.1`)
2. `ServerHello`
   - chosen version and cipher
   - key share / key exchange parameters
3. Certificate chain
   - server cert + intermediates (sometimes incomplete)
4. Certificate validation on client
   - chain trust, hostname, expiry, revocation policy (environment dependent)
5. Key agreement and session keys
6. Encrypted application data begins

Key terms:
- certificate chain: leaf -> intermediate(s) -> trusted root
- key exchange: ECDHE commonly used for forward secrecy
- cipher negotiation: selected algorithm suite from overlap

Enterprise troubleshooting commands:
```bash
openssl s_client -connect api.company.aero:443 -servername api.company.aero -showcerts
openssl s_client -connect api.company.aero:443 -servername api.company.aero -tls1_2
curl -vk --resolve api.company.aero:443:203.0.113.10 https://api.company.aero/health
```

Packet capture example (TLS):
```bash
sudo tcpdump -ni eth0 -s 0 -vvv 'tcp port 443 and host api.company.aero'
```

Log interpretation clues:
- `certificate verify failed` -> chain/trust/hostname/expiry issue
- `handshake failure` -> cipher/protocol mismatch
- `tlsv1 alert internal error` -> upstream TLS proxy/backend problem
- `unknown ca` -> missing trust chain or wrong internal CA distribution

## 3. L4 vs L7 Load Balancers (Architecture and Tradeoffs)

## L4 Load Balancer (Transport-level)

Routes based on IP/port and connection metadata.

Use cases:
- TLS passthrough
- TCP services (Postgres, Redis, custom protocols)
- very high throughput with lower overhead

Pros:
- lower latency/overhead
- simpler and protocol-agnostic
- preserves end-to-end TLS if passthrough

Cons:
- limited request-aware routing
- no HTTP header/path/cookie routing
- less app-level observability without side systems

## L7 Load Balancer (Application-level)

Routes based on HTTP headers, path, host, cookies, methods.

Use cases:
- API routing (`/v1/*`, `/ops/*`)
- auth, WAF policies, rate limiting
- canary/blue-green at HTTP layer

Pros:
- rich routing and policy controls
- better request-level logs/metrics
- easier traffic shaping and canarying

Cons:
- more CPU cost and complexity
- TLS termination/inspection increases security responsibility
- header/path misconfig can cause correctness incidents

## 4. NAT, SNAT, and DNAT (Enterprise Explanation)

## NAT roles
- `SNAT`: source NAT (outbound traffic appears from translated source IP)
- `DNAT`: destination NAT (incoming traffic redirected to internal destination)

Examples:
- SNAT for private subnets egressing to external APIs
- DNAT for inbound edge traffic forwarded to internal LB or proxy

Operational risks:
- SNAT port exhaustion under burst traffic
- log attribution loss if original client IP not preserved via headers/proxy protocol
- asymmetric routing if translations differ across paths

Evidence to collect:
- firewall/NAT gateway session stats
- conntrack usage (`conntrack -S`, `nf_conntrack_count`)
- translated flow logs (VPC flow logs / firewall logs)

## 5. Reverse Proxy vs Load Balancer (Difference)

Reverse proxy:
- an application-facing proxy that receives client requests and forwards to upstream servers
- often provides TLS termination, auth, caching, header rewriting, compression
- may load balance, but that is one capability among several

Load balancer:
- primarily distributes traffic across multiple backends for availability and scale
- can operate at L4 or L7
- may be managed service or proxy-based implementation

Practical enterprise reality:
- many products act as both (e.g., Nginx/Envoy/HAProxy/Ingress controllers)
- the distinction is about function and placement in architecture, not just tool name

## 6. DNS Resolution Path (Client -> Authoritative)

```text
Client stub resolver
  -> OS cache / local resolver
  -> Recursive resolver (enterprise DNS / ISP / public resolver)
  -> Root nameserver
  -> TLD nameserver (.aero, .com, etc.)
  -> Authoritative nameserver (company zone)
  -> Response cached (TTL) and returned to client
```

Enterprise complications:
- split-horizon DNS (internal vs external answers)
- private hosted zones
- forwarding rules from cluster DNS (CoreDNS) to enterprise resolvers
- DNSSEC, RPZ filtering, and cache poisoning mitigations

Debug commands:
```bash
dig api.company.aero
 dig +trace api.company.aero
 dig @10.20.0.10 api.company.aero
resolvectl query api.company.aero
```

## 7. MTU, Fragmentation, and Packet Loss Scenarios

MTU basics:
- Ethernet common MTU: `1500`
- tunnel overlays/VPNs can reduce effective MTU (e.g., `1450`, `1410`, etc.)

Failure pattern:
- Path MTU mismatch causes fragmentation or blackholing (especially if ICMP fragmentation-needed is filtered)
- symptoms can look like random API slowness, TLS handshake stalls, or intermittent large-response failures

Debug commands:
```bash
tracepath api.company.aero
ping -M do -s 1472 api.company.aero   # IPv4 example (1500 MTU path test)
ping -M do -s 1400 api.company.aero
sudo tcpdump -ni eth0 'icmp or (tcp and host api.company.aero)'
```

What to look for:
- retransmissions without obvious app CPU issues
- only large payload requests fail
- ICMP type 3 code 4 (fragmentation needed) missing/blocked

## 8. Stateful vs Stateless Services (Networking Impact)

Stateless services:
- easier to scale horizontally behind LBs
- connection affinity usually not required
- failures isolate more cleanly

Stateful services:
- require connection/session awareness, replication, quorum, or persistence guarantees
- failover often changes client routing and latency
- health checks and readiness semantics are more complex

Enterprise example:
- API backend stateless behind L7 ingress
- DB and Redis stateful in private subnets with stricter firewall rules and failover procedures

## 9. Firewall Design Patterns (Enterprise)

Patterns:
- default deny + explicit allow (recommended)
- tier-based segmentation (edge -> app -> data)
- service identity + network policy (Kubernetes) layered with subnet/firewall rules
- egress allow-list for production workloads
- separate management plane access controls

Operational requirements:
- rule ownership and change tickets
- change windows / emergency change process
- audit logs for accepts/denies on critical paths
- periodic recertification of rules

## 10. Network Segmentation (Subnets, DMZ, Internal Trust Boundaries)

Example segmentation model:
- `DMZ / Edge subnets`: public-facing LB/WAF only
- `App subnets`: API workloads, no direct internet ingress
- `Data subnets`: DB/Redis, no direct user traffic
- `Management subnets`: bastions, monitoring, CI runners, admins
- `Inter-region transit`: private backbone / controlled routing domain

Kubernetes mapping:
- namespace isolation + network policies map application trust boundaries
- subnet and node pool separation map infrastructure trust boundaries

## Production Packet Capture Examples (tcpdump Recipes)

## TLS handshake capture on ingress node
```bash
sudo tcpdump -ni any -s 0 -vvv \
  'host 198.51.100.20 and tcp port 443' -w tls-ingress-failure.pcap
```
Interpretation:
- Validate whether TCP handshake completes
- Confirm TLS `ClientHello`/`ServerHello` appears
- Check for repeated handshake attempts / `RST`

## DNS failure capture on node or resolver
```bash
sudo tcpdump -ni eth0 -s 0 -vvv 'udp port 53 or tcp port 53'
```
Interpretation:
- UDP retries, TCP fallback for large responses, `SERVFAIL` timing, unexpected upstream resolvers

## MTU / fragmentation troubleshooting capture
```bash
sudo tcpdump -ni eth0 -s 0 -vvv 'icmp or (host api.company.aero and tcp port 443)'
```
Interpretation:
- Look for ICMP fragmentation-needed, retransmits, MSS values in SYN packets

## Nginx upstream timeout capture (L7 proxy to app)
```bash
sudo tcpdump -ni eth0 -s 0 -vvv 'host 10.42.18.23 and tcp port 8080'
```
Interpretation:
- Distinguish app slowness vs network loss vs connection refusal

## Log Interpretation (Enterprise Examples)

Ingress / reverse proxy (`nginx`/`envoy`) clues:
- `upstream timed out` -> app response timeout or network path issue to upstream
- `no live upstreams` -> health checks failed / bad service discovery
- `SSL_do_handshake() failed` -> TLS backend or client TLS incompatibility
- `connection reset by peer` -> upstream app closed connection / idle timeout mismatch

Kubernetes clues:
- `ImagePullBackOff` -> registry / auth / DNS / network / image tag issues
- `FailedScheduling` -> capacity, taints, topology constraints
- `Readiness probe failed` -> app not ready, dependency issue, wrong probe config

Firewall / cloud flow log clues:
- repeated `REJECT` on health-check source ranges -> misconfigured health check allow rules
- short-lived `SYN` only flows with no reply -> upstream path blocked/unreachable

## Multi-Layer Debugging Walkthrough (Use for Any Networking Incident)

1. Define blast radius
   - which route(s), hostname(s), regions, environments, user groups are impacted?
2. Confirm symptom at user layer
   - synthetic checks, `curl`, browser/SDK errors, response codes, latency
3. Check L7 edge / proxy logs
   - ingress/LB logs, route matches, upstream errors, TLS alerts
4. Check L4 transport behavior
   - `ss`, `tcpdump`, SYN/SYN-ACK patterns, retransmits, RSTs, idle timeout behavior
5. Check service discovery / DNS
   - `dig`, resolver logs, CoreDNS/enterprise resolver health, TTL/cache behavior
6. Check segmentation/firewalls/NAT
   - flow logs, denies, SNAT port usage, security group / ACL / network policy changes
7. Check orchestration and endpoint health
   - pods/endpoints, readiness, node health, rollout changes, service selectors
8. Check infrastructure path
   - WAN/transit gateways, LB health targets, subnet routing, provider incidents
9. Correlate with recent changes
   - CI/CD deployment, GitOps sync, Terraform apply, cert rotation, firewall changes
10. Stabilize, then document RCA + preventative controls with evidence

## 10 Enterprise Networking Incidents (Aviation-Scale)

Each scenario below requires reasoning across application, container, orchestration, network, and infrastructure layers.

## Incident 1: TLS Handshake Failure Due to Expired Intermediate Certificate

Symptoms:
- Passenger API mobile clients fail TLS connection intermittently depending on client trust store behavior
- Some synthetic checks pass, others fail

Logs:
- Application:
  ```text
  INFO app healthy; no request reached backend during failure window
  ```
- Container (ingress proxy):
  ```text
  SSL_do_handshake() failed (SSL: error:0A000086:SSL routines::certificate verify failed)
  ```
- Orchestration:
  ```text
  Ingress secret updated successfully; no pod restarts
  ```
- Network:
  ```text
  Client TLS alert unknown_ca / certificate_expired (varies by client)
  ```
- Infrastructure:
  ```text
  Certificate bundle deployed without valid intermediate chain (intermediate expired 2026-02-21)
  ```

Root cause:
- Leaf certificate was valid, but the deployed chain contained an expired intermediate; some clients could not build trust path.

Mitigation:
- Redeploy full valid certificate chain bundle, verify with `openssl s_client -showcerts`, confirm client compatibility.

Preventative control:
- Automated cert-chain validation in CI/CD and pre-prod synthetic checks against multiple trust stores.

## Incident 2: MTU Mismatch Causing API Latency and Retransmits

Symptoms:
- Check-in API requests with larger JWTs or headers show high latency/timeouts; small requests succeed

Logs:
- Application:
  ```text
  WARN request timeout route=/checkin/confirm elapsed_ms=3001 body_size=9KB
  ```
- Container (ingress):
  ```text
  upstream timed out (110: Connection timed out) while reading response header from upstream
  ```
- Orchestration:
  ```text
  Pods healthy, no restarts, no rollout change
  ```
- Network:
  ```text
  tcpdump shows retransmissions; no ICMP fragmentation-needed seen
  ```
- Infrastructure:
  ```text
  New VPN tunnel path enforces MTU 1400; ICMP frag-needed filtered on firewall
  ```

Root cause:
- Path MTU decreased due to tunnel overhead; blocked ICMP prevented PMTUD, causing blackholing/retransmit delays.

Mitigation:
- Lower MTU/MSS clamping on affected path, allow ICMP fragmentation-needed, validate with `tracepath` and capture.

Preventative control:
- Standard MTU baselines for tunnel paths and automated PMTU validation during network changes.

## Incident 3: DNS Cache Poisoning Scenario (Conceptual Training)

Symptoms:
- A subset of internal clients resolves `dispatch-api.internal.aero` to unexpected IP and receives invalid TLS cert

Logs:
- Application:
  ```text
  ERROR outbound call failed tls hostname mismatch to dispatch-api.internal.aero
  ```
- Container:
  ```text
  resolver cache returns 10.99.88.77 (unexpected subnet)
  ```
- Orchestration:
  ```text
  CoreDNS healthy; issue isolated to branch-office resolver cluster
  ```
- Network:
  ```text
  DNS responses observed from unauthorized resolver IP on branch segment
  ```
- Infrastructure:
  ```text
  Branch DNS forwarder misconfigured to accept unauthenticated upstream responses
  ```

Root cause:
- Resolver security weakness and misconfiguration enabled poisoned cached response (training scenario, not exploit steps).

Mitigation:
- Flush caches, isolate affected resolvers, restore trusted forwarders, validate DNSSEC/response source controls.

Preventative control:
- DNSSEC where applicable, resolver hardening, egress filtering for DNS, monitoring for unexpected resolver sources.

## Incident 4: L7 Load Balancer Misrouting Traffic to Wrong Service

Symptoms:
- `/ops/*` requests are served by passenger API backend after ingress rule update

Logs:
- Application:
  ```text
  passenger-api INFO unexpected path /ops/crew/manifest returning 404
  ops-api traffic volume suddenly drops
  ```
- Container (ingress controller):
  ```text
  configuration reload complete; route host=api.company.aero path=/ mapped to passenger-api before /ops/
  ```
- Orchestration:
  ```text
  Ingress updated by GitOps sync revision 0f3a12
  ```
- Network:
  ```text
  Normal connectivity; no transport errors
  ```
- Infrastructure:
  ```text
  None degraded
  ```

Root cause:
- L7 path precedence/order misconfiguration caused greedy route to match before specific `/ops/` rule.

Mitigation:
- Revert ingress config, add explicit route-order tests, validate config render before production sync.

Preventative control:
- Ingress policy lint/tests in CI and canary validation using synthetic route checks.

## Incident 5: Firewall Blocking Health Checks

Symptoms:
- External load balancer marks targets unhealthy, but direct internal service tests succeed

Logs:
- Application:
  ```text
  No health check requests observed in app logs
  ```
- Container (ingress/app):
  ```text
  Service listening on 8443 and serving /healthz
  ```
- Orchestration:
  ```text
  Pod readiness/liveness probes green
  ```
- Network:
  ```text
  Firewall logs: DENY src=LB_HEALTHCHECK_RANGE dst=10.40.12.18:8443
  ```
- Infrastructure:
  ```text
  Security policy update removed managed LB health check CIDR allow-list
  ```

Root cause:
- Firewall/security group change blocked health-check source ranges, causing edge traffic removal.

Mitigation:
- Restore allow rules for health-check CIDRs and validate target health recovery.

Preventative control:
- Managed health-check CIDR references as code, with policy tests and drift detection.

## Incident 6: Cross-Region Latency Spike on Booking Search

Symptoms:
- `us-east` booking search p95 latency jumps from 250ms to 1.6s; error rate rises slightly

Logs:
- Application:
  ```text
  WARN downstream latency high service=fare-cache region=us-west elapsed_ms=920
  ```
- Container (service mesh sidecar):
  ```text
  endpoint priority set changed; locality failover active
  ```
- Orchestration:
  ```text
  mesh-config rollout started 5 minutes before latency spike
  ```
- Network:
  ```text
  inter-region RTT increased; packet loss 0.8% during provider maintenance
  ```
- Infrastructure:
  ```text
  WAN/transit maintenance advisory active
  ```

Root cause:
- Service mesh locality policy regression routed requests cross-region during WAN maintenance.

Mitigation:
- Roll back mesh route config, pin local endpoints, monitor latency normalization.

Preventative control:
- Route policy regression tests + alerting on unexpected cross-region dependency traffic.

## Incident 7: SYN Flood Behavior (Conceptual) Affecting Ingress Capacity

Symptoms:
- Edge ingress CPU and connection table usage spike; legitimate client connection success drops

Logs:
- Application:
  ```text
  App request volume lower than edge connection attempts; backend mostly idle
  ```
- Container (ingress / LB):
  ```text
  accept queue overflow; SYN_RECV count elevated
  ```
- Orchestration:
  ```text
  Ingress pods autoscaled but connection backlog remains high
  ```
- Network:
  ```text
  Large SYN rate from distributed sources with low ACK completion ratio
  ```
- Infrastructure:
  ```text
  DDoS protection alert: SYN flood pattern detected on VIP 203.0.113.40
  ```

Root cause:
- Volumetric SYN flood (conceptual scenario) saturating ingress connection handling before app layer.

Mitigation:
- Enable/raise SYN cookies, upstream DDoS mitigation/scrubbing, rate limiting, autoscale edge, shift traffic if necessary.

Preventative control:
- DDoS service integration, baseline SYN/ACK ratio alerting, edge capacity testing and runbooks.

## Incident 8: Broken Internal DNS Resolution in Kubernetes

Symptoms:
- `crew-scheduler` pods cannot resolve `postgres.internal.aero`; service returns 500s

Logs:
- Application:
  ```text
  ERROR db connect failed: getaddrinfo ENOTFOUND postgres.internal.aero
  ```
- Container:
  ```text
  /etc/resolv.conf nameserver 10.96.0.10 search svc.cluster.local cluster.local
  ```
- Orchestration:
  ```text
  CoreDNS pods running; ConfigMap updated recently
  ```
- Network:
  ```text
  CoreDNS logs show SERVFAIL forwarding to enterprise resolver
  ```
- Infrastructure:
  ```text
  Internal zone forwarding rule changed on enterprise DNS cluster
  ```

Root cause:
- Broken DNS forwarder path from cluster DNS to enterprise authoritative resolver.

Mitigation:
- Restore forwarders, validate `dig` from pod and node, reload CoreDNS if needed.

Preventative control:
- DNS synthetic checks from each cluster namespace and change review for forwarding policies.

## Incident 9: Nginx Upstream Timeout to API Pods

Symptoms:
- Public API returns `504 Gateway Timeout` from Nginx; pod CPU/memory look normal

Logs:
- Application:
  ```text
  WARN db_pool wait_time_ms=1800 active=200 max=200
  ```
- Container (nginx):
  ```text
  upstream timed out (110: Connection timed out) while reading response header from upstream
  ```
- Orchestration:
  ```text
  Pods Ready; HPA stable; no restart spike
  ```
- Network:
  ```text
  TCP connections from nginx to pods established; long server response time
  ```
- Infrastructure:
  ```text
  DB connection pool saturation due to slow queries after index regression
  ```

Root cause:
- Not a network transport outage: upstream timeout is caused by backend slowness from DB pool saturation.

Mitigation:
- Roll back DB/query change or add index, increase timeout only as temporary relief, scale app cautiously.

Preventative control:
- DB pool saturation alerts correlated with ingress 504s and query regression testing.

## Incident 10: Asymmetric Routing Issue Breaking Stateful Firewall Sessions

Symptoms:
- Intermittent API failures between app tier and auth service; SYN/SYN-ACK seen, later packets dropped/reset

Logs:
- Application:
  ```text
  ERROR auth request failed connection reset by peer after handshake request_id=7ac4
  ```
- Container:
  ```text
  retries exhausted to auth.internal.aero:8443
  ```
- Orchestration:
  ```text
  Services healthy; endpoints stable
  ```
- Network:
  ```text
  Firewall state table shows outbound flow on FW-A, return path arriving via FW-B (no session state)
  ```
- Infrastructure:
  ```text
  Route table change introduced ECMP path asymmetry across firewalls
  ```

Root cause:
- Asymmetric routing caused return traffic to bypass the firewall holding session state, resulting in drops/resets.

Mitigation:
- Restore symmetric routing (policy-based routing / consistent hashing / state sync), verify session continuity.

Preventative control:
- Route-change validation with path symmetry tests and firewall state-sync design for HA pairs.

## Enterprise Networking Cheatsheet

## Core commands
```bash
ip a
ip r
ss -tulpn
ss -s
ethtool -k eth0
ethtool -S eth0
```

## DNS
```bash
dig api.company.aero
dig +trace api.company.aero
dig @<resolver_ip> api.company.aero
resolvectl status
```

## TLS
```bash
openssl s_client -connect api.company.aero:443 -servername api.company.aero -showcerts
curl -vk https://api.company.aero/health
```

## Packet capture
```bash
sudo tcpdump -ni any -s 0 -vvv 'tcp port 443'
sudo tcpdump -ni any -s 0 -w capture.pcap 'host <ip> and (tcp or udp)'
```

## MTU / path
```bash
tracepath api.company.aero
ping -M do -s 1472 api.company.aero
mtr -rwzbc 50 api.company.aero
```

## Kubernetes networking checks
```bash
kubectl get svc,endpoints -A
kubectl get networkpolicy -A
kubectl logs -n ingress-nginx deploy/ingress-nginx-controller --tail=200
kubectl exec -it <pod> -- sh
```

## Firewall / conntrack (host-dependent)
```bash
sudo nft list ruleset
sudo iptables -S
sudo conntrack -S
sudo sysctl net.netfilter.nf_conntrack_count
```

## Enterprise Debug Sequence (fast)
```text
Symptom -> Blast radius -> L7 logs -> L4 packets -> DNS -> Firewall/NAT -> Orchestration -> Infra path -> Recent changes -> Mitigate -> RCA
```

## Interview-Level Explanations (Senior Engineer Style)

## Explain TCP vs UDP in one minute

TCP provides reliable, ordered byte-stream delivery with congestion and flow control, which makes it ideal for transactional APIs but sensitive to loss and timeout tuning. UDP is connectionless and lower overhead, so reliability and ordering must be implemented by the application protocol (for example QUIC). In production, the important difference is operational behavior under loss, rate limiting, and state tracking by middleboxes.

## Explain L4 vs L7 load balancing in one minute

L4 load balancers distribute connections using transport-level metadata (IP/port), making them efficient and protocol-agnostic. L7 load balancers understand application protocols (typically HTTP), enabling path/header routing, WAF, auth, and canary delivery at the cost of more complexity and CPU. In enterprise systems, both are often used together: L7 at the edge and L4 for internal TCP services or TLS passthrough.

## Explain why MTU issues are hard to diagnose

MTU problems often manifest as intermittent latency or timeouts rather than clean failures. Small requests may work while larger packets fail, and if ICMP fragmentation-needed is blocked, path MTU discovery fails silently, leading to retransmissions and stalls. This is why packet captures, MSS inspection, and `tracepath` are key tools.

## Explain reverse proxy vs load balancer accurately

A reverse proxy is a server-side intermediary that can terminate TLS, enforce policy, cache, rewrite, and forward requests to upstreams. A load balancer is primarily focused on distributing traffic for scale and availability. Many modern tools do both, so the correct answer is about role and placement, not product branding.

## Explain asymmetric routing risk to a firewall team

Stateful firewalls track sessions. If a path change causes return traffic to traverse a different firewall that lacks session state, packets can be dropped even though routes and endpoints look healthy. Any HA firewall design must address path symmetry or share state reliably.

## Repeatable Practice Without AI (Suggested Weekly Routine)

1. Run packet captures for TLS, DNS, and HTTP traffic on a non-production training environment.
2. Trace DNS from client to authoritative and document each hop.
3. Reproduce an MTU issue in a sandbox (e.g., with `tc`/tunnels) and validate the fix.
4. Review one incident from this module and write your own RCA in `docs/`.
5. Practice the multi-layer debug sequence from memory.

## Live Project (Repeatable Exercises)

- `../projects/enterprise-networking-lab/README.md`
