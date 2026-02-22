#!/usr/bin/env bash
set -euo pipefail

kubectl create namespace argocd --dry-run=client -o yaml | kubectl apply -f -
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
kubectl -n argocd rollout status deploy/argocd-server --timeout=300s
kubectl -n argocd get pods

echo "Minikube access options:"
echo "  kubectl -n argocd port-forward svc/argocd-server 8080:443"
echo "  argocd admin initial-password -n argocd"
