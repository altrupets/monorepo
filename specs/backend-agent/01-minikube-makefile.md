# PASO 1: Verificar Minikube + Namespace + Integración Makefile

## 1.1 Minikube ya está configurado

El script `infrastructure/scripts/start-minikube.sh` ejecuta:

```bash
minikube start --driver=podman --cpus=8 --memory=16384 --disk-size=50g
```

Verificar que está corriendo:

```bash
make dev-minikube-deploy   # usa el target existente
kubectl cluster-info
```

## 1.2 Namespace altrupets-dev

El namespace se crea via Kustomize (`k8s/overlays/dev/backend/namespace.yaml`). Asegurar contexto:

```bash
kubectl config set-context --current --namespace=altrupets-dev
```

## 1.3 Auditoría de Targets Existentes

Targets que **NO se duplican**:

| Target existente | Función | Reutilizable |
|---|---|---|
| `dev-minikube-deploy` | Crear cluster | Si |
| `dev-backend-build` | Build + load imagen backend | Patrón a replicar para agent |
| `dev-backend-tf-deploy` | `kubectl apply -k` backend | Patrón a replicar |
| `dev-infisical-sync` | Sync secrets | Agregar secrets de agent |
| `dev-gateway-deploy` | Deploy Gateway API | Agregar HTTPRoute para agent |
| `dev-images-build` | Build todas las imágenes | Extender con agent |

## 1.4 Nuevos Targets — Append al Makefile

Agregar al Makefile existente (**antes de `.DEFAULT_GOAL`**):

```makefile
# ==========================================
# DEV - Agent AI (LangGraph + Zep + FalkorDB)
# ==========================================

dev-agent-build: ## Build agent image and load into minikube
	@echo "$(BLUE)Building agent image...$(NC)"
	@$(SCRIPTS_DIR)/build-agent-image-minikube.sh
	@kubectl rollout restart deployment/agent -n altrupets-dev 2>/dev/null || true
	@kubectl rollout status deployment/agent -n altrupets-dev --timeout=120s 2>/dev/null || true
	@echo "$(GREEN)✓ Agent image built$(NC)"

dev-agent-deploy: ## Deploy agent + FalkorDB to minikube (kustomize)
	@echo "$(BLUE)Deploying FalkorDB...$(NC)"
	@kubectl apply -k k8s/overlays/dev/falkordb --server-side
	@echo "$(BLUE)Deploying Agent...$(NC)"
	@kubectl apply -k k8s/overlays/dev/agent --server-side
	@kubectl rollout status deployment/falkordb -n altrupets-dev --timeout=120s
	@kubectl rollout status deployment/agent -n altrupets-dev --timeout=120s
	@echo "$(GREEN)✓ Agent + FalkorDB deployed$(NC)"

dev-agent-destroy: ## Remove agent + FalkorDB from minikube
	@kubectl delete -k k8s/base/agent -n altrupets-dev --ignore-not-found=true
	@kubectl delete -k k8s/base/falkordb -n altrupets-dev --ignore-not-found=true
	@echo "$(GREEN)✓ Agent + FalkorDB removed$(NC)"

dev-agent-start: ## Start agent in dev mode (hot-reload, no k8s)
	@cd apps/agent && npm run start:dev

dev-agent-logs: ## Show agent logs
	@kubectl logs -n altrupets-dev -l app=agent --tail=100 -f

dev-falkordb-logs: ## Show FalkorDB logs
	@kubectl logs -n altrupets-dev -l app=falkordb --tail=100 -f

dev-agent-port-forward: ## Port-forward agent GraphQL (localhost:3002)
	@pkill -f "kubectl port-forward.*agent-service" 2>/dev/null || true
	@kubectl port-forward -n altrupets-dev svc/agent-service 3002:3002

dev-falkordb-port-forward: ## Port-forward FalkorDB (localhost:6379)
	@pkill -f "kubectl port-forward.*falkordb" 2>/dev/null || true
	@kubectl port-forward -n altrupets-dev svc/falkordb-service 6379:6379
```

Actualizar el `.PHONY` al inicio del Makefile:

```makefile
        dev-agent-build dev-agent-deploy dev-agent-destroy dev-agent-start \
        dev-agent-logs dev-falkordb-logs dev-agent-port-forward dev-falkordb-port-forward \
```

Y actualizar `dev-images-build` para incluir agent:

```makefile
dev-images-build: ## Build all images (backend + agent + web apps)
	@echo "$(BLUE)Building all images...$(NC)"
	@$(SCRIPTS_DIR)/build-backend-image-minikube.sh
	@$(SCRIPTS_DIR)/build-agent-image-minikube.sh
	@$(SCRIPTS_DIR)/build-web-images-minikube.sh superusers
	@$(SCRIPTS_DIR)/build-web-images-minikube.sh b2g
	@echo "$(GREEN)✓ All images built$(NC)"
```
