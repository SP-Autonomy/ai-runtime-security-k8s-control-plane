KIND_CLUSTER=airs
KUBECONFIG_CONTEXT=kind-airs

.PHONY: kind-up kind-down ns install-ollama install-airs install-app uninstall-app uninstall-airs status demo

kind-up:
	kind create cluster --config clusters/kind/kind-config.yaml
	kubectl config use-context $(KUBECONFIG_CONTEXT)

kind-down:
	kind delete cluster --name $(KIND_CLUSTER)

ns:
	kubectl apply -f helm/namespaces.yaml

install-ollama:
	kubectl apply -f helm/ollama/ollama.yaml

install-airs:
	@echo "Installing AIRS-CP (expects vendor/airs-cp Helm chart path)"
	@echo "Edit scripts/install_airs.sh with correct chart path + values"
	bash scripts/install_airs.sh

install-app:
	helm upgrade --install agentic-app helm/agentic-app -n ai-app

uninstall-app:
	helm uninstall agentic-app -n ai-app || true

uninstall-airs:
	bash scripts/uninstall_airs.sh

status:
	kubectl get pods -A
	kubectl get svc -A

demo:
	@echo "TODO: run attacks and validate incidents via AIRS-CP API/DB"
