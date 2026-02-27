./scripts/delete_base.sh
kubectl -n platform-lab get all || true
# optional full cleanup
# minikube delete --profile platform-lab
