kubectl -n platform-prod rollout status deploy/podinfo --timeout=180s
kubectl -n argocd get applications.argoproj.io podinfo-prod
# stop the port-forward with Ctrl+C in the terminal running it
