#!/usr/bin/env bash
set -euo pipefail

cat <<'MSG'
K3s quick start (requires sudo + network):

curl -sfL https://get.k3s.io | sh -
sudo kubectl get nodes
sudo cp /etc/rancher/k3s/k3s.yaml ~/.kube/config
sudo chown "$USER":"$USER" ~/.kube/config
kubectl config current-context

Notes:
- K3s usually includes Traefik by default.
- If you want nginx ingress instead, install ingress-nginx and set `ingressClassName` accordingly.
- HPA requires metrics-server availability (often included in recent K3s setups, verify with `kubectl get apiservices`).
MSG
