# Section 5 - Kubernetes Local Platform

Source docs:

- `docs/kubernetes-local-lab.md`
- `projects/kubernetes-local-lab/README.md`

## What Type Of Software Engineering This Is

Platform engineering and orchestration operations. You are managing desired state (manifests) and verifying actual runtime state (pods/services/ingress).

## Definitions

- `cluster`: a Kubernetes control plane + worker nodes.
- `namespace`: logical isolation boundary inside a cluster.
- `deployment`: desired state for a replicated app.
- `pod`: smallest schedulable runtime unit.
- `service`: stable network access to pods.
- `ingress`: HTTP routing into services.

## Concepts And Theme

Always compare desired state vs actual state before trying to fix anything.

## 1. Step 1 - Read the lab and verify prerequisites

```bash
cd /home/sp/cyber-course/projects/DevOps
sed -n '1,220p' projects/kubernetes-local-lab/README.md
kubectl version --client
minikube version
```

What you are doing: confirming the learning path and checking the core CLIs (`kubectl`, `minikube`) exist.

## 2. Step 2 - Start a local cluster (Minikube path)

```bash
cd /home/sp/cyber-course/projects/DevOps/projects/kubernetes-local-lab
./scripts/start_minikube.sh
kubectl config current-context
kubectl get nodes -o wide
```

What you are doing: creating a local Kubernetes cluster with ingress + metrics so the lab manifests can run.

## 3. Step 3 - Apply the base platform resources

```bash
./scripts/apply_base.sh
kubectl get ns
kubectl -n platform-lab get deploy,rs,pods,svc,ingress,cm,secret,hpa
kubectl -n platform-lab describe deploy podinfo
```

What you are doing: applying the lab manifests and verifying core resources were created and scheduled.

## 4. Step 4 - Test reachability and observe a rollout

```bash
minikube ip
curl -H 'Host: podinfo.local' http://$(minikube ip)
./scripts/rolling_update_demo.sh
kubectl -n platform-lab rollout status deploy/podinfo --timeout=120s
kubectl -n platform-lab rollout history deploy/podinfo
```

What you are doing: proving traffic reaches the app through ingress and watching a controlled deployment update.

## 5. Step 5 - Clean up resources (keep or remove cluster)

```bash
./scripts/delete_base.sh
kubectl -n platform-lab get all || true
# optional full cleanup
# minikube delete --profile platform-lab
```

What you are doing: removing lab resources while optionally keeping the cluster for the GitOps section.

## Done Check

You can say where a failure lives: manifest config, pod/runtime, service routing, or ingress path.
