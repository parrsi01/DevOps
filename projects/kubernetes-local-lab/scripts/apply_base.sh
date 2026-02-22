#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."

kubectl apply -f manifests/base/00-namespaces.yaml
kubectl apply -f manifests/base/01-configmap.yaml
kubectl apply -f manifests/base/02-secret.yaml
kubectl apply -f manifests/base/03-deployment-podinfo.yaml
kubectl apply -f manifests/base/04-replicaset-standalone.yaml
kubectl apply -f manifests/base/05-service-clusterip.yaml
kubectl apply -f manifests/base/06-service-nodeport.yaml
kubectl apply -f manifests/base/07-ingress.yaml
kubectl apply -f manifests/base/08-hpa-target-deployment.yaml
kubectl apply -f manifests/base/08a-hpa-target-service.yaml
kubectl apply -f manifests/base/09-hpa.yaml

kubectl -n platform-lab rollout status deploy/podinfo --timeout=120s
kubectl -n platform-lab get deploy,rs,pods,svc,ingress,hpa
