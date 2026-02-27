./scripts/bootstrap_argocd_apps.sh
kubectl -n argocd get applications.argoproj.io
kubectl -n argocd port-forward svc/argocd-server 8080:443
