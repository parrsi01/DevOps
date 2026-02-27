minikube ip
curl -H 'Host: podinfo.local' http://$(minikube ip)
./scripts/rolling_update_demo.sh
kubectl -n platform-lab rollout status deploy/podinfo --timeout=120s
kubectl -n platform-lab rollout history deploy/podinfo
