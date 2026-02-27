./scripts/apply_base.sh
kubectl get ns
kubectl -n platform-lab get deploy,rs,pods,svc,ingress,cm,secret,hpa
kubectl -n platform-lab describe deploy podinfo
