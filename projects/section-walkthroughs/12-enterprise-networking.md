# Section 12 - Enterprise Networking

Source docs:

- `docs/enterprise-networking-lab.md`
- `projects/enterprise-networking-lab/README.md`

## What Type Of Software Engineering This Is

Network operations engineering and evidence-based protocol troubleshooting (DNS, TCP, TLS, HTTP).

## Definitions

- `DNS`: translates names to IP addresses.
- `TCP handshake`: connection setup between client and server.
- `TLS handshake`: encryption/session setup on top of TCP.
- `timeout`: request waits too long for a response.
- `packet capture`: recorded network packets used for evidence.

## Concepts And Theme

Find the first failing protocol layer (DNS -> TCP -> TLS -> HTTP) before changing configs.

## 1. Step 1 - Read the module and run preflight

```bash
cd /home/sp/cyber-course/projects/DevOps
sed -n '1,180p' projects/enterprise-networking-lab/README.md
cd projects/enterprise-networking-lab
./scripts/preflight.sh
```

What you are doing: checking required tools and understanding the lab exercises before running packet-capture recipes.

## 2. Step 2 - Generate DNS path troubleshooting commands

```bash
./scripts/capture_dns_path.sh api.company.aero eth0
```

What you are doing: printing a DNS evidence recipe (tcpdump + `dig` + `dig +trace`) so you can prove where name resolution fails.

## 3. Step 3 - Generate TLS handshake capture commands

```bash
./scripts/capture_tls_handshake.sh api.company.aero 443 eth0
```

What you are doing: printing a TLS packet-capture + `openssl s_client` workflow to prove whether encryption negotiation succeeds.

## 4. Step 4 - Generate HTTP timeout troubleshooting commands

```bash
./scripts/capture_http_timeout.sh api.company.aero 443 eth0
tracepath api.company.aero
ping -M do -s 1472 api.company.aero
ping -M do -s 1400 api.company.aero
```

What you are doing: combining timeout analysis with MTU/PMTU checks to separate application slowness from path/network transport issues.

## 5. Step 5 - Prepare an incident evidence note from the template

```bash
cd /home/sp/cyber-course/projects/DevOps/projects/enterprise-networking-lab
sed -n '1,220p' templates/incident-note-template.md
```

What you are doing: reviewing the note format you should use after every capture exercise (command, interface, timestamps, hypothesis, conclusion).

## Done Check

You can say which layer failed first and what command/capture proves it.
