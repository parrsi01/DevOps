# Kubernetes Local Lab Notes

Live project: `projects/kubernetes-local-lab/`

Covers:

- Minikube or K3s local cluster setup
- `kubectl` configuration
- namespaces, pods, deployments, ReplicaSets
- services (`ClusterIP`, `NodePort`)
- ingress controller
- ConfigMaps and Secrets
- requests/limits
- HPA autoscaling
- rolling updates
- failure simulations and troubleshooting

Start here:

```bash
cd projects/kubernetes-local-lab
./scripts/start_minikube.sh    # preferred path
./scripts/apply_base.sh
```

If using K3s instead, read `./scripts/start_k3s.sh` first and adjust ingress class if needed.
