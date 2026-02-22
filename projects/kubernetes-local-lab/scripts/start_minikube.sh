#!/usr/bin/env bash
set -euo pipefail

PROFILE="${MINIKUBE_PROFILE:-platform-lab}"
DRIVER="${MINIKUBE_DRIVER:-docker}"
CPUS="${MINIKUBE_CPUS:-4}"
MEMORY="${MINIKUBE_MEMORY:-6144}"

minikube start --profile "$PROFILE" --driver "$DRIVER" --cpus "$CPUS" --memory "$MEMORY"
minikube addons enable ingress --profile "$PROFILE"
minikube addons enable metrics-server --profile "$PROFILE"
kubectl config use-context "$PROFILE"
kubectl cluster-info
