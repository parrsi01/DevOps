#!/usr/bin/env bash
set -euo pipefail


# Block 1 from 05-kubernetes-local-platform
cd /home/sp/cyber-course/projects/DevOps
sed -n '1,220p' projects/kubernetes-local-lab/README.md
kubectl version --client
minikube version


# Block 2 from 05-kubernetes-local-platform
cd /home/sp/cyber-course/projects/DevOps/projects/kubernetes-local-lab
./scripts/start_minikube.sh
kubectl config current-context
kubectl get nodes -o wide


# Block 3 from 05-kubernetes-local-platform
./scripts/apply_base.sh
kubectl get ns
kubectl -n platform-lab get deploy,rs,pods,svc,ingress,cm,secret,hpa
kubectl -n platform-lab describe deploy podinfo


# Block 4 from 05-kubernetes-local-platform
minikube ip
curl -H 'Host: podinfo.local' http://$(minikube ip)
./scripts/rolling_update_demo.sh
kubectl -n platform-lab rollout status deploy/podinfo --timeout=120s
kubectl -n platform-lab rollout history deploy/podinfo


# Block 5 from 05-kubernetes-local-platform
./scripts/delete_base.sh
kubectl -n platform-lab get all || true
# optional full cleanup
# minikube delete --profile platform-lab

