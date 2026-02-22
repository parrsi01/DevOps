# Enterprise Networking Lab (Live Exercises + Packet Capture Recipes)

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

This project provides repeatable networking diagnostics exercises and command recipes you can run from a Linux host, VM, or lab node.

## What This Project Contains

- `scripts/preflight.sh` - verify required tools are installed
- `scripts/capture_tls_handshake.sh` - wrapper for TLS packet capture
- `scripts/capture_dns_path.sh` - wrapper for DNS capture and query trace
- `scripts/capture_http_timeout.sh` - wrapper for upstream timeout capture
- `templates/incident-note-template.md` - repeatable RCA note format

## Preflight

```bash
cd /home/sp/cyber-course/projects/DevOps/projects/enterprise-networking-lab
./scripts/preflight.sh
```

## Beginner Exercises (Repeatable)

## 1. DNS path tracing (enterprise hostname)
```bash
./scripts/capture_dns_path.sh api.company.aero eth0
```
What to record:
- resolver used
- TTL
- authority path (`dig +trace`)
- whether internal vs external answers differ

## 2. TLS handshake capture
```bash
./scripts/capture_tls_handshake.sh api.company.aero 443 eth0
```
What to record:
- handshake completion
- certificate chain seen by client
- protocol/cipher negotiated

## 3. HTTP timeout evidence capture
```bash
./scripts/capture_http_timeout.sh api.company.aero 443 eth0
```
What to record:
- SYN/SYN-ACK timing
- retransmissions
- TLS vs application-layer timeout clues

## Intermediate Exercises

## 4. MTU and PMTU validation
```bash
tracepath api.company.aero
ping -M do -s 1472 api.company.aero
ping -M do -s 1400 api.company.aero
```
Record:
- largest non-fragmenting size
- ICMP behavior
- evidence of blackholing/retransmits

## 5. Reverse proxy log + packet correlation
- Tail ingress logs in one terminal
- Run `capture_http_timeout.sh` in another
- Generate traffic (`curl`, synthetic checks)
- Correlate request IDs and timestamps

## Advanced Exercises (Enterprise-Style)

## 6. Kubernetes service path debug (cluster lab required)
```bash
kubectl get svc,endpoints -A
kubectl get networkpolicy -A
kubectl logs -n ingress-nginx deploy/ingress-nginx-controller --tail=200
kubectl exec -it <pod> -- sh
```
Goal:
- prove or disprove DNS / service selector / network policy / upstream timeout hypotheses

## 7. Firewall / conntrack state analysis (host privileges required)
```bash
sudo nft list ruleset
sudo conntrack -S
sudo tcpdump -ni any -s 0 -vvv 'host <peer_ip> and (tcp or udp)'
```
Goal:
- identify drops, session table pressure, or asymmetric flow behavior

## Audit and Evidence Checklist (Use for Every Exercise)

- date/time and timezone
- host/node/jumpbox used
- interface captured (`eth0`, `ens5`, etc.)
- exact command used
- sanitized output snippets / packet timestamps
- hypothesis and conclusion
- mitigation tested (if any)

## Safety Notes

- Do not capture sensitive production traffic without authorization.
- Use approved maintenance windows and packet-capture approvals in enterprise environments.
- Sanitize captures before sharing (credentials, tokens, passenger data, PII).

## Companion Theory + Incident Module

- `../../docs/enterprise-networking-lab.md`
