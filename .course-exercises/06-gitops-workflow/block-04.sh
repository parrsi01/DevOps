./scripts/render_overlay.sh dev
./scripts/render_overlay.sh staging
./scripts/render_overlay.sh prod
./scripts/show_version_matrix.sh
./scripts/simulate_config_drift.sh
kubectl -n platform-prod scale deploy/podinfo --replicas=7
kubectl -n platform-prod get deploy podinfo
kubectl -n argocd get applications.argoproj.io podinfo-prod
