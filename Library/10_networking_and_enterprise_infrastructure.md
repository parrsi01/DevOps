# Networking and Enterprise Infrastructure

---

> **Field** — DevOps / Network Engineering and Architecture
> **Scope** — Networking protocols, enterprise architecture, and infrastructure audit concepts from the networking and architecture labs

---

## Overview

Many application failures are actually network path
failures. This section covers networking protocols
from DNS through TLS, enterprise architecture concepts
like multi-region design and disaster recovery, and
the audit and refactoring practices used to raise
infrastructure to production grade.

---

## Definitions

### `DNS (Domain Name System)`

**Definition.**
A system that converts human-readable names (like
api.example.com) into IP addresses that computers
use to route traffic. DNS is the first step in
every network connection.

**Context.**
If DNS fails, nothing else works. DNS debugging
is always the first layer to check when "cannot
connect" errors appear.

**Example.**
```bash
dig api.example.com
# shows DNS resolution path and result

nslookup api.example.com
# simpler DNS lookup
```

---

### `TCP (Transmission Control Protocol)`

**Definition.**
A reliable connection protocol that ensures data
arrives in order and without loss. TCP is used by
HTTP, HTTPS, SSH, databases, and most application
protocols.

**Context.**
TCP connection failures indicate routing, firewall,
or listener issues. If DNS resolves but TCP fails,
the problem is between the client and the server
port.

**Example.**
```bash
nc -zv api.example.com 443
# tests if a TCP connection can be established

ss -tulpn | grep :443
# checks if anything is listening on port 443
```

---

### `TLS (Transport Layer Security)`

**Definition.**
An encryption layer that provides secure communication
over a network. TLS is what makes HTTPS secure. It
verifies server identity through certificates and
encrypts data in transit.

**Context.**
TLS handshake failures are caused by expired
certificates, protocol mismatches, or cipher suite
incompatibilities. These failures look like
"connection reset" but are actually security-layer
issues.

**Example.**
```bash
openssl s_client -connect api.example.com:443
# shows TLS handshake details, certificate chain,
# and protocol version

curl -v https://api.example.com
# verbose output includes TLS negotiation
```

---

### `HTTP (Hypertext Transfer Protocol)`

**Definition.**
The request/response protocol used by web browsers
and APIs. HTTP defines methods (GET, POST, PUT,
DELETE), status codes (200, 404, 500), headers,
and body content.

**Context.**
HTTP errors at the application layer mean DNS, TCP,
and TLS all succeeded. The problem is in the
application logic, configuration, or backend
services.

**Example.**
```bash
curl -v http://localhost:8080/health
# shows request headers, response status, body

# Status codes:
# 200 = OK
# 404 = Not Found
# 500 = Internal Server Error
# 502 = Bad Gateway (upstream server error)
# 503 = Service Unavailable
```

---

### `NAT (Network Address Translation)`

**Definition.**
A technique that rewrites network addresses as
traffic passes through a router or firewall. NAT
allows private IP addresses to access public
networks.

**Context.**
NAT issues can cause containers and VMs to lose
outbound connectivity. Docker and Kubernetes both
use NAT rules to route traffic between containers
and the host network.

**Example.**
```bash
iptables -t nat -L
# shows current NAT rules

# Docker creates NAT rules to map
# container ports to host ports
```

---

### `Load Balancer`

**Definition.**
A device or software that distributes incoming
network traffic across multiple backend servers.
Load balancers improve availability by routing
around unhealthy backends.

**Context.**
Load balancers are the entry point for production
services. They perform health checks on backends
and only route traffic to healthy ones.

**Example.**
```
Client → Load Balancer → Backend 1 (healthy)
                       → Backend 2 (healthy)
                       → Backend 3 (unhealthy, skipped)
```

---

### `Packet Capture`

**Definition.**
Recording network traffic at the packet level for
analysis. Packet captures show exactly what data
was sent and received, including headers, timing,
and protocol details.

**Context.**
Packet captures are the strongest evidence for
network debugging. They prove what actually happened
on the wire, removing guesswork.

**Example.**
```bash
./scripts/capture_dns_path.sh api.example.com eth0
# captures DNS resolution traffic

./scripts/capture_tls_handshake.sh \
  api.example.com 443 eth0
# captures TLS handshake traffic

tcpdump -i eth0 port 443 -w capture.pcap
# raw packet capture to file
```

---

### `Firewall`

**Definition.**
A network security system that controls incoming
and outgoing traffic based on rules. Firewalls
block unauthorized connections and allow authorized
ones.

**Context.**
Firewall rules are a common cause of "it works
locally but not from outside" issues. Docker and
Kubernetes both interact with the host firewall
(iptables).

**Example.**
```bash
iptables -L -n
# shows current firewall rules

ufw status
# shows UFW firewall status (Ubuntu)
```

---

### `Subnet`

**Definition.**
A logical subdivision of an IP network. Subnets
group IP addresses together and control how traffic
is routed between different parts of a network.

**Context.**
Understanding subnets is essential for configuring
Docker networks, Kubernetes pod networks, and cloud
VPCs (Virtual Private Clouds).

**Example.**
```
10.0.0.0/24
# a subnet with 256 addresses (10.0.0.0 - 10.0.0.255)
# /24 means the first 24 bits are the network part
```

---

### `Architecture`

**Definition.**
The high-level design of a system's components,
their interactions, data flows, and the decisions
that shaped them. Architecture defines how parts
fit together.

**Context.**
Understanding architecture lets you predict failure
modes, recovery paths, and security boundaries.
Architecture is a set of decisions, not just a
diagram.

**Example.**
An architecture decision: "We use three availability
zones so a single zone failure does not cause an
outage."

---

### `Multi-Region`

**Definition.**
Running services in more than one geographic region
so that a regional failure does not cause a global
outage. Data and traffic are distributed across
regions.

**Context.**
Multi-region architectures are complex and expensive
but provide the highest level of availability. They
require data replication, traffic routing, and
failover automation.

**Example.**
```
Region A (primary) ← normal traffic
Region B (standby) ← failover target
Data replicated between regions
```

---

### `DR (Disaster Recovery)`

**Definition.**
The plan and procedures for restoring service after
a major failure or disaster. DR covers backup,
restore, failover, and recovery time objectives.

**Context.**
DR planning answers: how long can the service be
down (RTO - Recovery Time Objective) and how much
data can be lost (RPO - Recovery Point Objective)?

**Example.**
DR plan components:
- Backup frequency: every 6 hours
- RPO: 6 hours of data loss maximum
- RTO: 2 hours to restore service
- Failover: automatic to standby region

---

### `Trust Boundary`

**Definition.**
A point in the system where security assumptions
change. Traffic crossing a trust boundary requires
authentication, authorization, or encryption.

**Context.**
Trust boundaries exist between public internet and
private network, between services in different
namespaces, and between user-facing and internal
APIs.

**Example.**
```
Public Internet ──[trust boundary]── Load Balancer
                                         │
Internal Network ──[trust boundary]── Database
```

---

### `Control Plane`

**Definition.**
The management layer that configures, orchestrates,
and monitors the data plane. In Kubernetes, the
control plane includes the API server, scheduler,
and controller manager.

**Context.**
Control plane failures affect the ability to manage
the system but may not immediately affect running
workloads. Existing pods continue running even if
the Kubernetes API server is temporarily down.

**Example.**
```bash
kubectl get componentstatuses
# checks control plane component health
```

---

### `Audit`

**Definition.**
A structured review to verify that controls,
evidence, and practices meet operational standards.
Audits check what is actually in place, not what
is assumed.

**Context.**
Infrastructure audits identify gaps in logging,
rollback capability, security, and documentation
that increase operational risk.

**Example.**
Audit checklist:
- [ ] Are logs structured and retained?
- [ ] Is rollback tested and documented?
- [ ] Are secrets managed securely?
- [ ] Is the change process documented?

---

### `Traceability`

**Definition.**
The ability to follow a change from initial request
through implementation to production deployment,
with evidence at each step.

**Context.**
Traceability requires linking tickets, commits,
pull requests, CI runs, and deployment events.
It is essential for regulated environments.

**Example.**
Ticket TKT-042 → Branch fix/tkt-042 → PR #15 →
CI run #278 → Deploy to staging → Deploy to prod

---

### `Refactor`

**Definition.**
Improving the structure, organization, or quality
of a system without changing its intended behavior.
Refactoring makes systems easier to maintain and
operate.

**Context.**
The enterprise audit and refactor program in this
course takes working labs and raises them to
production-grade standards through systematic
improvement.

**Example.**
Refactoring a Docker setup:
- Before: single-stage build, runs as root, no health check
- After: multi-stage build, non-root user, health check, structured logging

---

## Network Debugging Order

Always debug in layer order. If an earlier layer
fails, later layers produce misleading errors.

```
1. DNS    → did the name resolve?
2. TCP    → did the connection establish?
3. TLS    → did the handshake succeed?
4. HTTP   → did the application respond correctly?
```

---

## Key Commands Summary

```bash
# DNS
dig <domain>
nslookup <domain>

# TCP
nc -zv <host> <port>
ss -tulpn

# TLS
openssl s_client -connect <host>:<port>

# HTTP
curl -v <url>

# Network info
ip a
ip route

# Firewall
iptables -L -n
ufw status

# Packet capture
tcpdump -i <interface> port <port> -w <file>.pcap
```

---

## See Also

- [Linux and System Administration](./01_linux_and_system_administration.md)
- [Containers and Docker](./02_containers_and_docker.md)
- [Universal DevOps Concepts](./00_universal_devops_concepts.md)

---

> **Author** — Simon Parris | DevOps Reference Library
