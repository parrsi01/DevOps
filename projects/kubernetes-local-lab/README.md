# Kubernetes Local Platform Lab (Minikube or K3s)

Acting as a Senior Platform Engineer: this lab gives you a repeatable, production-style Kubernetes training environment on a local machine.

Primary path: `Minikube` (recommended for first run)
Alternative path: `K3s` (lightweight single-node cluster)

This lab includes:

- cluster installation + `kubectl` configuration
- namespace isolation
- pod lifecycle
- deployments + ReplicaSets
- services (`ClusterIP`, `NodePort`)
- ingress controller
- ConfigMaps + Secrets
- resource requests & limits
- autoscaling (HPA)
- rolling updates
- 7 failure simulations with debugging workflows

## Repository Layout

- `manifests/base/` - normal lab resources
- `manifests/scenarios/` - broken resources for failure simulation drills
- `scripts/` - helpers for cluster start, apply, cleanup, load generation

## Prerequisites

Install locally (this VM currently does not have these installed):

- `kubectl`
- `minikube` (for primary path) or `k3s`
- Docker (if using Minikube Docker driver)

Verify:

```bash
kubectl version --client
minikube version
# or
k3s --version
```

## 1. Cluster Installation

## Option A (Primary): Minikube

### Start cluster + ingress + metrics-server

```bash
cd projects/kubernetes-local-lab
./scripts/start_minikube.sh
```

This runs:

- `minikube start`
- `minikube addons enable ingress`
- `minikube addons enable metrics-server`
- `kubectl config use-context <profile>`

### Manual equivalent commands

```bash
minikube start --profile platform-lab --driver docker --cpus 4 --memory 6144
minikube addons enable ingress --profile platform-lab
minikube addons enable metrics-server --profile platform-lab
kubectl config use-context platform-lab
kubectl cluster-info
kubectl get nodes -o wide
```

## Option B (Alternative): K3s

Read helper instructions:

```bash
./scripts/start_k3s.sh
```

Typical install flow:

```bash
curl -sfL https://get.k3s.io | sh -
sudo kubectl get nodes
sudo cp /etc/rancher/k3s/k3s.yaml ~/.kube/config
sudo chown "$USER":"$USER" ~/.kube/config
kubectl get nodes
```

Notes:

- K3s often ships with Traefik ingress controller by default.
- This lab manifests use `ingressClassName: nginx`; adjust if using Traefik (or install `ingress-nginx`).
- HPA requires metrics API availability.

## 2. kubectl Configuration

Check contexts and active cluster:

```bash
kubectl config get-contexts
kubectl config current-context
kubectl cluster-info
kubectl get nodes
```

Useful config commands:

```bash
kubectl config use-context platform-lab
kubectl config view --minify
```

## 3. Namespace Isolation

Apply namespaces (included in base manifests):

```bash
kubectl apply -f manifests/base/00-namespaces.yaml
kubectl get ns
```

Why this matters:

- separates workloads logically (team/env/app)
- reduces command mistakes (`-n platform-lab`)
- supports RBAC and quota isolation in real environments

Isolation checks:

```bash
kubectl get all -n platform-lab
kubectl get all -n tenant-b
kubectl get all -A | head
```

## 4. Apply the Base Lab

```bash
./scripts/apply_base.sh
```

Verify core resources:

```bash
kubectl -n platform-lab get deploy,rs,pods,svc,ingress,cm,secret,hpa
kubectl -n platform-lab describe deploy podinfo
```

## 5. Pod Lifecycle (Create -> Running -> Succeeded/Failed)

Create a one-shot pod:

```bash
kubectl -n platform-lab run lifecycle-demo \
  --image=busybox:1.36 \
  --restart=Never \
  -- sh -c 'echo starting; sleep 3; echo done; exit 0'
```

Watch lifecycle:

```bash
kubectl -n platform-lab get pod lifecycle-demo -w
kubectl -n platform-lab describe pod lifecycle-demo
kubectl -n platform-lab logs lifecycle-demo
```

Common phases you will see:

- `Pending` (scheduling / image pull)
- `Running`
- `Succeeded` (completed) or `Failed`

Cleanup:

```bash
kubectl -n platform-lab delete pod lifecycle-demo
```

## 6. Deployments and ReplicaSets

The lab creates:

- `Deployment/podinfo` (managed rolling updates)
- `ReplicaSet/tools-rs` (standalone ReplicaSet demo)

Inspect:

```bash
kubectl -n platform-lab get deploy
kubectl -n platform-lab get rs
kubectl -n platform-lab describe deploy podinfo
kubectl -n platform-lab get pods -l app=podinfo -o wide
```

Key concept:

- Deployments manage ReplicaSets.
- ReplicaSets ensure a target number of matching pods exist.
- Rolling updates happen via new ReplicaSet creation + old ReplicaSet scale-down.

## 7. Services (ClusterIP and NodePort)

This lab creates both:

- `Service/podinfo` (`ClusterIP`) for in-cluster access
- `Service/podinfo-nodeport` (`NodePort`) for local external testing

Inspect:

```bash
kubectl -n platform-lab get svc
kubectl -n platform-lab get endpoints podinfo
```

### ClusterIP test (from another pod)

```bash
kubectl -n platform-lab run curl --rm -it --image=curlimages/curl:8.9.1 -- \
  curl -s http://podinfo
```

### NodePort test (from host)

Minikube:

```bash
minikube service podinfo-nodeport -n platform-lab --url
# or use node IP + nodePort
curl http://$(minikube ip):30080
```

K3s/single-node local:

```bash
kubectl -n platform-lab get svc podinfo-nodeport
curl http://127.0.0.1:30080
```

## 8. Ingress Controller

Base manifest includes `Ingress/podinfo` with host `podinfo.local`.

Inspect:

```bash
kubectl -n platform-lab get ingress
kubectl -n platform-lab describe ingress podinfo
```

### Host mapping for local testing (Minikube)

```bash
minikube ip
# Add to /etc/hosts (example):
# <MINIKUBE_IP> podinfo.local
```

Test:

```bash
curl -H 'Host: podinfo.local' http://$(minikube ip)
# or after /etc/hosts entry
curl http://podinfo.local
```

Ingress controller logs (nginx ingress):

```bash
kubectl -n ingress-nginx get pods
kubectl -n ingress-nginx logs deploy/ingress-nginx-controller --tail=100
```

## 9. ConfigMaps and Secrets

Inspect:

```bash
kubectl -n platform-lab get configmap podinfo-config -o yaml
kubectl -n platform-lab get secret podinfo-secret -o yaml
```

See env injection in the pod spec:

```bash
kubectl -n platform-lab describe pod -l app=podinfo | rg -n 'Environment|PODINFO|DB_PASSWORD|API_TOKEN'
```

Secret handling notes:

- Secrets are base64-encoded in Kubernetes, not encrypted by default unless encryption-at-rest is enabled.
- Avoid printing secret values in logs.
- Prefer external secret managers for production.

## 10. Resource Requests and Limits

Pod `podinfo` and `hpa-demo` containers define requests/limits.

Inspect:

```bash
kubectl -n platform-lab describe pod -l app=podinfo | rg -n 'Requests|Limits|cpu|memory'
```

If metrics-server is working:

```bash
kubectl top pods -n platform-lab
kubectl top nodes
```

Why this matters:

- `requests` influence scheduling
- `limits` cap resource usage
- too-low limits can cause throttling or OOMKilled

## 11. Autoscaling (HPA)

The lab includes:

- `Deployment/hpa-demo` (CPU-based HPA target)
- `HPA/hpa-demo`

Inspect HPA:

```bash
kubectl -n platform-lab get hpa
kubectl -n platform-lab describe hpa hpa-demo
```

Generate load:

```bash
./scripts/hpa_loadgen.sh
kubectl -n platform-lab get hpa -w
kubectl -n platform-lab get deploy hpa-demo -w
```

Cleanup load generator:

```bash
kubectl -n platform-lab delete pod hpa-loadgen
```

If HPA shows metrics errors:

```bash
kubectl get apiservices | rg metrics
kubectl -n kube-system get pods | rg metrics-server
```

## 12. Rolling Updates

Base `podinfo` deployment uses `RollingUpdate` strategy.

Perform a rolling update:

```bash
kubectl -n platform-lab set image deploy/podinfo podinfo=ghcr.io/stefanprodan/podinfo:6.7.2
kubectl -n platform-lab rollout status deploy/podinfo --timeout=120s
kubectl -n platform-lab rollout history deploy/podinfo
kubectl -n platform-lab get rs
```

Rollback:

```bash
kubectl -n platform-lab rollout undo deploy/podinfo
kubectl -n platform-lab rollout status deploy/podinfo
```

What to watch:

- new ReplicaSet created
- old ReplicaSet scaled down gradually
- pod readiness gates control rollout progress

## 13. Failure Simulations (Reason Across Layers)

Each scenario includes commands, logs/events, root cause, and a step-by-step fix.

## A. CrashLoopBackOff

### Simulate

```bash
kubectl apply -f manifests/scenarios/crashloopbackoff.yaml
kubectl -n platform-lab get pods -l app=crashloop-demo -w
```

### Debug commands

```bash
kubectl -n platform-lab describe pod -l app=crashloop-demo
kubectl -n platform-lab logs deploy/crashloop-demo --previous
kubectl -n platform-lab get events --sort-by=.lastTimestamp | tail -n 20
```

### Example logs / events
```text
starting
fatal startup error

Warning  BackOff  kubelet  Back-off restarting failed container
```

### Root Cause
Container command exits with status `1`, so Kubernetes restarts it repeatedly under the deployment.

### Fix (step by step)

1. Inspect command/entrypoint in pod spec
2. Patch deployment to a valid long-running command or correct image/args
3. Verify pod reaches `Running`

Example fix:

```bash
kubectl -n platform-lab set image deploy/crashloop-demo crashloop-demo=busybox:1.36
kubectl -n platform-lab patch deploy crashloop-demo --type='json' \
  -p='[{"op":"replace","path":"/spec/template/spec/containers/0/command","value":["sh","-c","while true; do echo ok; sleep 30; done"]}]'
kubectl -n platform-lab rollout status deploy/crashloop-demo
```

Cleanup:

```bash
kubectl -n platform-lab delete deploy crashloop-demo
```

## B. ImagePullBackOff

### Simulate

```bash
kubectl apply -f manifests/scenarios/imagepullbackoff.yaml
kubectl -n platform-lab get pods -l app=imagepull-demo -w
```

### Debug commands

```bash
kubectl -n platform-lab describe pod -l app=imagepull-demo
kubectl -n platform-lab get events --sort-by=.lastTimestamp | tail -n 20
```

### Example events (no container logs yet)
```text
Warning  Failed     kubelet  Failed to pull image "ghcr.io/stefanprodan/podinfo:not-a-real-tag": manifest unknown
Warning  Failed     kubelet  Error: ErrImagePull
Normal   BackOff    kubelet  Back-off pulling image
Warning  Failed     kubelet  Error: ImagePullBackOff
```

### Root Cause
Deployment references a non-existent image tag, so the container never starts.

### Fix (step by step)

1. Confirm tag exists in registry (or check CI publish job)
2. Patch image to a valid immutable tag/digest
3. Watch rollout complete

```bash
kubectl -n platform-lab set image deploy/imagepull-demo imagepull-demo=ghcr.io/stefanprodan/podinfo:6.7.1
kubectl -n platform-lab rollout status deploy/imagepull-demo
```

Cleanup:

```bash
kubectl -n platform-lab delete deploy imagepull-demo
```

## C. Pod OOMKilled

### Simulate

```bash
kubectl apply -f manifests/scenarios/oomkilled.yaml
kubectl -n platform-lab get pods -l app=oom-demo -w
```

### Debug commands

```bash
kubectl -n platform-lab describe pod -l app=oom-demo
kubectl -n platform-lab logs deploy/oom-demo --previous
kubectl -n platform-lab get events --sort-by=.lastTimestamp | tail -n 20
```

### Example events
```text
Last State:   Terminated
  Reason:     OOMKilled
  Exit Code:  137
Warning  OOMKilled  kubelet  Container oom-demo was killed due to memory limit
```

### Root Cause
The container intentionally allocates memory continuously but has a `64Mi` memory limit.

### Fix (step by step)

1. Confirm `Reason: OOMKilled`
2. Review `resources.limits.memory`
3. Increase memory limit or fix application memory usage
4. Redeploy and observe stable pod

Example fix:

```bash
kubectl -n platform-lab patch deploy oom-demo --type='merge' -p '{"spec":{"template":{"spec":{"containers":[{"name":"oom-demo","resources":{"requests":{"memory":"128Mi","cpu":"50m"},"limits":{"memory":"256Mi","cpu":"200m"}}}]}}}}'
kubectl -n platform-lab rollout status deploy/oom-demo
```

Cleanup:

```bash
kubectl -n platform-lab delete deploy oom-demo
```

## D. Service Not Reachable (Selector Mismatch)

### Simulate

```bash
kubectl apply -f manifests/scenarios/service-not-reachable.yaml
kubectl -n platform-lab get svc podinfo-broken
kubectl -n platform-lab get endpoints podinfo-broken
```

### Debug commands

```bash
kubectl -n platform-lab describe svc podinfo-broken
kubectl -n platform-lab get pods -l app=podinfo
kubectl -n platform-lab run curl-test --rm -it --image=curlimages/curl:8.9.1 -- \
  curl -sv --max-time 3 http://podinfo-broken
```

### Example output
```text
Endpoints:  <none>
curl: (28) Operation timed out after 3001 milliseconds with 0 bytes received
```

### Root Cause
Service selector is `app: podinfo-typo` but actual pods are labeled `app: podinfo`, so no endpoints are attached.

### Fix (step by step)

1. Compare service selector vs pod labels
2. Patch selector to match real pods
3. Re-check endpoints and connectivity

```bash
kubectl -n platform-lab patch svc podinfo-broken --type='merge' -p '{"spec":{"selector":{"app":"podinfo"}}}'
kubectl -n platform-lab get endpoints podinfo-broken
kubectl -n platform-lab run curl-test --rm -it --image=curlimages/curl:8.9.1 -- curl -s http://podinfo-broken
```

Cleanup:

```bash
kubectl -n platform-lab delete svc podinfo-broken
```

## E. Ingress Misconfiguration

### Simulate

```bash
kubectl apply -f manifests/scenarios/ingress-misconfiguration.yaml
kubectl -n platform-lab get ingress podinfo-broken
```

### Debug commands

```bash
kubectl -n platform-lab describe ingress podinfo-broken
kubectl -n platform-lab get svc podinfo -o yaml | rg -n 'port:|targetPort:'
kubectl -n ingress-nginx logs deploy/ingress-nginx-controller --tail=100 | rg -i 'podinfo-broken|platform-lab/podinfo|9999'
curl -H 'Host: podinfo-broken.local' http://$(minikube ip) -v
```

### Example symptoms
```text
HTTP/1.1 502 Bad Gateway
...
nginx-ingress ... Service "platform-lab/podinfo" does not have a service port 9999
```

### Root Cause
Ingress backend references service port `9999`, but `Service/podinfo` exposes port `80`.

### Fix (step by step)

1. Inspect ingress backend port
2. Inspect service ports
3. Patch ingress to service port `80`
4. Re-test request

```bash
kubectl -n platform-lab patch ingress podinfo-broken --type='json' \
  -p='[{"op":"replace","path":"/spec/rules/0/http/paths/0/backend/service/port/number","value":80}]'
kubectl -n platform-lab describe ingress podinfo-broken
```

Cleanup:

```bash
kubectl -n platform-lab delete ingress podinfo-broken
```

## F. Liveness Probe Failure

### Simulate

```bash
kubectl apply -f manifests/scenarios/liveness-probe-failure.yaml
kubectl -n platform-lab get pods -l app=liveness-fail-demo -w
```

### Debug commands

```bash
kubectl -n platform-lab describe pod -l app=liveness-fail-demo
kubectl -n platform-lab logs deploy/liveness-fail-demo --previous
kubectl -n platform-lab get events --sort-by=.lastTimestamp | tail -n 20
```

### Example events
```text
Warning  Unhealthy  kubelet  Liveness probe failed: HTTP probe failed with statuscode: 404
Normal   Killing    kubelet  Container podinfo failed liveness probe, will be restarted
```

### Root Cause
Liveness probe path `/does-not-exist` returns `404`, so kubelet kills and restarts an otherwise healthy container.

### Fix (step by step)

1. Confirm the probe failure in `describe pod`
2. Patch liveness path to `/healthz`
3. Wait for rollout and confirm restart loop stops

```bash
kubectl -n platform-lab patch deploy liveness-fail-demo --type='json' \
  -p='[{"op":"replace","path":"/spec/template/spec/containers/0/livenessProbe/httpGet/path","value":"/healthz"}]'
kubectl -n platform-lab rollout status deploy/liveness-fail-demo
```

Cleanup:

```bash
kubectl -n platform-lab delete deploy liveness-fail-demo
```

## G. Readiness Probe Failure

### Simulate

```bash
kubectl apply -f manifests/scenarios/readiness-probe-failure.yaml
kubectl -n platform-lab get pods -l app=readiness-fail-demo -w
```

### Debug commands

```bash
kubectl -n platform-lab describe pod -l app=readiness-fail-demo
kubectl -n platform-lab get pod -l app=readiness-fail-demo
kubectl -n platform-lab get endpointslices -l kubernetes.io/service-name=podinfo | head
kubectl -n platform-lab get events --sort-by=.lastTimestamp | tail -n 20
```

### Example events
```text
Warning  Unhealthy  kubelet  Readiness probe failed: Get "http://10.244.0.25:9999/readyz": dial tcp ...: connect: connection refused
```

### Root Cause
Readiness probe points to port `9999`, but the container listens on `9898`. Pod stays `Running` but `Ready=False`.

### Fix (step by step)

1. Confirm `Ready=False` with repeated readiness probe failures
2. Inspect container port and probe port mismatch
3. Patch readiness probe port to `http` or `9898`
4. Verify pod becomes `1/1 Ready`

```bash
kubectl -n platform-lab patch deploy readiness-fail-demo --type='json' \
  -p='[{"op":"replace","path":"/spec/template/spec/containers/0/readinessProbe/httpGet/port","value":"http"}]'
kubectl -n platform-lab rollout status deploy/readiness-fail-demo
kubectl -n platform-lab get pods -l app=readiness-fail-demo
```

Cleanup:

```bash
kubectl -n platform-lab delete deploy readiness-fail-demo
```

## 14. Namespace + Service + Ingress Reasoning Pattern (Why These Incidents Matter)

These failures look similar to users (“service is down”) but occur in different layers:

- `CrashLoopBackOff` -> app process/container startup layer
- `ImagePullBackOff` -> registry/image/pipeline artifact layer
- `OOMKilled` -> resource limits/runtime behavior layer
- Service unreachable -> service selector/endpoints layer
- Ingress misconfig -> L7 routing/controller layer
- Liveness failure -> self-healing misconfiguration (kills healthy app)
- Readiness failure -> traffic gating misconfiguration (app runs, no traffic)

The key platform skill is isolating the failing layer before changing anything.

## 15. Cleanup

Delete scenarios only:

```bash
./scripts/cleanup_scenarios.sh
```

Delete base lab:

```bash
./scripts/delete_base.sh
```

Delete namespaces (if desired):

```bash
kubectl delete ns platform-lab tenant-b
```

## Kubernetes Troubleshooting Cheatsheet

## Cluster / Context

```bash
kubectl config get-contexts
kubectl config current-context
kubectl cluster-info
kubectl get nodes -o wide
kubectl get events -A --sort-by=.lastTimestamp | tail -n 50
```

## Namespaces

```bash
kubectl get ns
kubectl get all -n <ns>
kubectl config set-context --current --namespace=<ns>
```

## Pods

```bash
kubectl get pods -n <ns>
kubectl get pods -n <ns> -o wide
kubectl describe pod <pod> -n <ns>
kubectl logs <pod> -n <ns>
kubectl logs <pod> -n <ns> --previous
kubectl exec -it <pod> -n <ns> -- sh
```

## Deployments / ReplicaSets / Rollouts

```bash
kubectl get deploy,rs -n <ns>
kubectl describe deploy <deploy> -n <ns>
kubectl rollout status deploy/<deploy> -n <ns>
kubectl rollout history deploy/<deploy> -n <ns>
kubectl rollout undo deploy/<deploy> -n <ns>
kubectl set image deploy/<deploy> <container>=<image> -n <ns>
```

## Services / Endpoints

```bash
kubectl get svc -n <ns>
kubectl describe svc <svc> -n <ns>
kubectl get endpoints <svc> -n <ns>
kubectl get endpointslices -n <ns>
kubectl get pods -n <ns> --show-labels
```

## Ingress

```bash
kubectl get ingress -n <ns>
kubectl describe ingress <ing> -n <ns>
kubectl -n ingress-nginx logs deploy/ingress-nginx-controller --tail=100
curl -H 'Host: <host>' http://<ingress-ip>
```

## Config / Secrets

```bash
kubectl get configmap -n <ns>
kubectl get secret -n <ns>
kubectl describe configmap <name> -n <ns>
kubectl describe secret <name> -n <ns>
kubectl get pod <pod> -n <ns> -o yaml | rg -n 'envFrom|configMapRef|secretRef'
```

## Resources / HPA

```bash
kubectl top pods -n <ns>
kubectl top nodes
kubectl describe pod <pod> -n <ns> | rg -n 'Requests|Limits'
kubectl get hpa -n <ns>
kubectl describe hpa <name> -n <ns>
```

## Quick Triage Decision Tree

1. `kubectl get pods` -> is it `Running`, `Ready`, `CrashLoopBackOff`, `ImagePullBackOff`?
2. `kubectl describe pod` -> events/probes/image pulls/OOM
3. `kubectl logs --previous` -> last crash reason
4. `kubectl get svc/endpoints` -> does service have endpoints?
5. `kubectl describe ingress` + ingress controller logs -> routing errors?
6. `kubectl rollout history` -> did a recent deploy introduce it?
7. `kubectl top` / limits -> resource pressure or OOM?

## Validation Note

This lab was scaffolded and reviewed in-repo, but `kubectl`, `minikube`, and `k3s` were not installed on this VM at build time, so commands/manifests were not executed here. Run the quick start steps after installing the tooling to validate locally.
