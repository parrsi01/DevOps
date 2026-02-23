# Kubernetes

---

> **Field** — DevOps / Container Orchestration
> **Scope** — Kubernetes concepts and commands from the local platform lab

---

## Overview

Kubernetes is a platform for running, scaling, and
managing containerized applications across a cluster
of machines. It adds a control plane layer on top
of Docker containers. The key debugging skill is
separating desired state (what you configured) from
actual state (what the cluster is doing).

---

## Definitions

### `Cluster`

**Definition.**
A group of machines (nodes) running Kubernetes
workloads. A cluster has a control plane that
manages scheduling and a set of worker nodes
that run application containers.

**Context.**
In this course, you use a local cluster (Minikube
or kind). In production, clusters span multiple
machines and often multiple availability zones.

**Example.**
```bash
minikube start
# creates a local single-node cluster

kubectl cluster-info
# shows control plane endpoint
```

---

### `Pod`

**Definition.**
The smallest deployable unit in Kubernetes. A pod
contains one or more containers that share networking
and storage. Most pods contain a single container.

**Context.**
Pods are ephemeral. When a pod dies, Kubernetes
creates a new one. You almost never create pods
directly. Instead, you use Deployments or other
controllers that manage pods for you.

**Example.**
```bash
kubectl get pods
# lists all pods in the current namespace

kubectl describe pod my-app-xyz
# shows pod events, status, and container details

kubectl logs my-app-xyz
# shows container logs from the pod
```

---

### `Deployment`

**Definition.**
A controller that manages a set of identical pods.
You specify the desired number of replicas and the
container image. The Deployment ensures that many
pods are always running.

**Context.**
Deployments handle rolling updates, rollbacks, and
scaling. When you change the image tag, the Deployment
gradually replaces old pods with new ones.

**Example.**
```bash
kubectl get deployments
# lists all deployments

kubectl rollout status deployment/my-app
# shows rollout progress

kubectl rollout undo deployment/my-app
# rolls back to previous version
```

---

### `Service`

**Definition.**
A stable network endpoint that routes traffic to
a set of pods. Pods come and go, but the Service
provides a consistent DNS name and IP address.

**Context.**
Services use label selectors to find their target
pods. If the selector does not match any pod labels,
the Service exists but routes traffic nowhere. This
is a common debugging scenario.

**Example.**
```bash
kubectl get svc
# lists all services

kubectl describe svc my-app-service
# shows endpoints (pod IPs) the service routes to
```

---

### `Namespace`

**Definition.**
A logical partition within a cluster. Namespaces
isolate resources so that different teams or
environments can share a cluster without conflict.

**Context.**
Default namespaces include `default`, `kube-system`,
and `kube-public`. Production clusters use namespaces
to separate dev, staging, and production workloads.

**Example.**
```bash
kubectl get ns
# lists all namespaces

kubectl get pods -n kube-system
# lists pods in the kube-system namespace

kubectl get pods -A
# lists pods across all namespaces
```

---

### `Ingress`

**Definition.**
An API object that manages external HTTP/HTTPS
access to services in the cluster. Ingress defines
routing rules that map hostnames and paths to
backend services.

**Context.**
Ingress is the entry point for web traffic into
the cluster. Without it, services are only
reachable from inside the cluster. An Ingress
controller (like nginx) must be running for
Ingress rules to work.

**Example.**
```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: my-app-ingress
spec:
  rules:
  - host: my-app.local
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: my-app-service
            port:
              number: 80
```

---

### `Manifest`

**Definition.**
A YAML or JSON file that describes a Kubernetes
resource. Manifests declare the desired state:
what kind of resource, what name, how many replicas,
which image, what ports.

**Context.**
Manifests are the "code" in Kubernetes. They are
version-controlled and applied to the cluster.
A manifest can apply successfully while pods still
fail later, so always verify runtime status.

**Example.**
```bash
kubectl apply -f deployment.yaml
# creates or updates resources from the manifest

kubectl delete -f deployment.yaml
# removes resources defined in the manifest
```

---

### `HPA (Horizontal Pod Autoscaler)`

**Definition.**
A Kubernetes controller that automatically scales
the number of pod replicas based on observed metrics
like CPU or memory usage.

**Context.**
HPA ensures your application can handle traffic
spikes without manual intervention. It scales up
when load increases and scales down when load drops.

**Example.**
```bash
kubectl get hpa
# shows autoscaler status, current/target metrics

kubectl autoscale deployment my-app \
  --min=2 --max=10 --cpu-percent=80
# creates an HPA targeting 80% CPU
```

---

### `ConfigMap`

**Definition.**
A Kubernetes object that stores non-sensitive
configuration data as key-value pairs. Pods
reference ConfigMaps to get configuration without
hardcoding values in the image.

**Context.**
ConfigMaps decouple configuration from container
images. Changing a ConfigMap and restarting pods
is faster than rebuilding images.

**Example.**
```bash
kubectl create configmap my-config \
  --from-literal=LOG_LEVEL=info

kubectl get configmap my-config -o yaml
```

---

### `Secret`

**Definition.**
A Kubernetes object that stores sensitive data
like passwords, tokens, or certificates. Secrets
are base64-encoded (not encrypted by default)
and mounted into pods.

**Context.**
Secrets keep sensitive values out of manifests
and images. In production, use external secret
managers and encryption at rest.

**Example.**
```bash
kubectl create secret generic db-creds \
  --from-literal=password=mysecret

kubectl get secret db-creds -o yaml
```

---

### `kubectl`

**Definition.**
The command-line tool for interacting with
Kubernetes clusters. It sends API requests to
the cluster control plane to create, inspect,
update, and delete resources.

**Context.**
kubectl is your primary interface to Kubernetes.
Learning its commands is essential for both
operations and debugging.

**Example.**
```bash
kubectl get all
# shows pods, services, deployments in current namespace

kubectl describe pod <name>
# detailed info including events and errors

kubectl exec -it <pod> -- /bin/bash
# open a shell inside a running pod
```

---

## Common Failure Signatures

```
ImagePullBackOff
  → image name/tag wrong or registry unreachable

CrashLoopBackOff
  → container starts and immediately fails
  → check: kubectl logs <pod>

Pending
  → not enough resources or node selector mismatch

Service exists but no response
  → selector mismatch or pod not ready
  → check: kubectl describe svc <name>
```

---

## Key Commands Summary

```bash
# Cluster
minikube start
kubectl cluster-info

# Resources
kubectl get pods/svc/deploy/ns -A
kubectl describe <resource> <name>
kubectl apply -f <manifest>.yaml
kubectl delete -f <manifest>.yaml

# Debugging
kubectl logs <pod>
kubectl exec -it <pod> -- /bin/bash
kubectl get events --sort-by=.metadata.creationTimestamp

# Scaling
kubectl scale deployment <name> --replicas=3
kubectl get hpa
```

---

## See Also

- [Containers and Docker](./02_containers_and_docker.md)
- [GitOps and Version Control](./06_gitops_and_version_control.md)
- [Deployment Strategies](./09_deployment_strategies.md)

---

> **Author** — Simon Parris | DevOps Reference Library
