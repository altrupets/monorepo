# Altrupets Monorepo - Automation Makefile
# ==========================================
# 
# Naming Convention: env-recurso-verbo
# Examples:
#   make dev-terraform-deploy    # Deploy terraform resources in dev
#   make dev-argocd-deploy       # Deploy ArgoCD in dev
#   make dev-minikube-clear      # Clear stuck namespaces
#
# Usage:
#   make <target> [ENV=<environment>]

.PHONY: help setup \
        dev-terraform-deploy dev-terraform-destroy \
        dev-minikube-deploy dev-minikube-clear dev-minikube-destroy \
        dev-argocd-deploy dev-argocd-destroy dev-argocd-status dev-argocd-password \
        dev-gateway-deploy dev-gateway-start dev-gateway-stop \
        dev-postgres-deploy dev-postgres-destroy dev-postgres-logs dev-postgres-port-forward \
        dev-backend-build dev-backend-start \
        dev-superusers-start dev-superusers-stop dev-superusers-deploy dev-superusers-destroy \
        dev-b2g-start dev-b2g-stop dev-b2g-deploy dev-b2g-destroy \
        dev-infisical-sync dev-infisical-sync-cli \
        dev-mcp-start dev-mcp-stop dev-mcp-status \
        dev-security-scan dev-security-deps dev-security-sast dev-security-secrets \
        dev-security-container dev-security-iac dev-security-fix \
        qa-terraform-deploy qa-terraform-destroy qa-verify \
        qa-gateway-deploy qa-postgres-deploy \
        stage-terraform-deploy stage-terraform-destroy stage-verify \
        stage-gateway-deploy stage-postgres-deploy \
        prod-deploy prod-emergency-deploy \
        ci-backend-build ci-backend-push ci-all-test

# ==========================================
# Variables
# ==========================================

ENV ?= dev
TF_DIR = infrastructure/terraform/environments/$(ENV)
SCRIPTS_DIR = infrastructure/scripts
APPS_DIR = apps
REPO_URL ?= https://github.com/altrupets/monorepo.git
VERSION ?= $(shell git describe --tags --always 2>/dev/null || echo "dev")
GIT_SHA ?= $(shell git rev-parse --short HEAD 2>/dev/null || echo "unknown")
IMAGE_TAG = $(VERSION)-$(GIT_SHA)
GITHUB_REGISTRY = ghcr.io/altrupets

BLUE := \033[36m
GREEN := \033[32m
YELLOW := \033[33m
RED := \033[31m
NC := \033[0m

# ==========================================
# Help
# ==========================================

help: ## Show this help message
	@echo ""
	@echo "$(BLUE)╔════════════════════════════════════════════════════════════════╗$(NC)"
	@echo "$(BLUE)║       Altrupets Monorepo - Commands (env-recurso-verbo)        ║$(NC)"
	@echo "$(BLUE)╚════════════════════════════════════════════════════════════════╝$(NC)"
	@echo ""
	@echo "$(GREEN)Quick Start (Full Setup):$(NC)"
	@echo "  $(YELLOW)One-liner:$(NC)"
	@echo "  make setup && make dev-minikube-deploy && make dev-gateway-deploy && make dev-backend-build && make dev-superusers-deploy && make dev-b2g-deploy && make dev-security-build && make dev-security-scan && make dev-gateway-start"
	@echo ""
	@echo "  $(YELLOW)Step by step:$(NC)"
	@echo "  1. make setup                    $(BLUE)# First time setup$(NC)"
	@echo "  2. make dev-minikube-deploy      $(BLUE)# Create minikube cluster$(NC)"
	@echo "  3. make dev-gateway-deploy       $(BLUE)# Deploy Gateway API (instala CRDs)$(NC)"
	@echo "  4. make dev-backend-build        $(BLUE)# Build backend image$(NC)"
	@echo "  5. make dev-superusers-deploy    $(BLUE)# Deploy CRUD Superusers$(NC)"
	@echo "  6. make dev-b2g-deploy           $(BLUE)# Deploy B2G$(NC)"
	@echo "  7. make dev-security-build       $(BLUE)# Build security scanner$(NC)"
	@echo "  8. make dev-security-scan        $(BLUE)# Run security scans$(NC)"
	@echo "  9. make dev-gateway-start        $(BLUE)# Start port-forward (localhost:3001)$(NC)"
	@echo ""
	@echo "  $(YELLOW)Después del setup:$(NC)"
	@echo "  make dev-mobile-launch           $(BLUE)# Launch Flutter app (Android/Desktop)$(NC)"
	@echo "  # O directamente: cd apps/mobile && ./launch_flutter_debug.sh"
	@echo ""
	@echo "$(GREEN)DEV - Minikube:$(NC)"
	@echo "  $(YELLOW)dev-minikube-deploy$(NC)         Create minikube cluster"
	@echo "  $(YELLOW)dev-minikube-clear$(NC)          Clear stuck namespaces (finalizers)"
	@echo "  $(YELLOW)dev-minikube-destroy$(NC)        Delete minikube cluster"
	@echo ""
	@echo "$(GREEN)DEV - Terraform:$(NC)"
	@echo "  $(YELLOW)dev-terraform-deploy$(NC)        Deploy all terraform resources"
	@echo "  $(YELLOW)dev-terraform-destroy$(NC)       Destroy all terraform resources"
	@echo ""
	@echo "$(GREEN)DEV - ArgoCD:$(NC)"
	@echo "  $(YELLOW)dev-argocd-deploy$(NC)           Install ArgoCD + all apps (backend, superusers, b2g)"
	@echo "  $(YELLOW)dev-argocd-destroy$(NC)          Remove ArgoCD namespace"
	@echo "  $(YELLOW)dev-argocd-status$(NC)           Show ArgoCD applications"
	@echo "  $(YELLOW)dev-argocd-password$(NC)         Get ArgoCD admin password"
	@echo ""
	@echo "$(GREEN)DEV - Gateway:$(NC)"
	@echo "  $(YELLOW)dev-gateway-deploy$(NC)          Deploy Gateway API"
	@echo "  $(YELLOW)dev-gateway-start$(NC)           Start port-forward (localhost:3001)"
	@echo "  $(YELLOW)dev-gateway-stop$(NC)            Stop port-forward"
	@echo ""
	@echo "$(GREEN)DEV - PostgreSQL:$(NC)"
	@echo "  $(YELLOW)dev-postgres-deploy$(NC)         Deploy PostgreSQL"
	@echo "  $(YELLOW)dev-postgres-destroy$(NC)        Destroy PostgreSQL"
	@echo "  $(YELLOW)dev-postgres-logs$(NC)           Show PostgreSQL logs"
	@echo "  $(YELLOW)dev-postgres-port-forward$(NC)   Port-forward PostgreSQL"
	@echo ""
	@echo "$(GREEN)DEV - Backend:$(NC)"
	@echo "  $(YELLOW)dev-backend-build$(NC)           Build backend image"
	@echo "  $(YELLOW)dev-backend-start$(NC)           Start backend in dev mode"
	@echo "  $(YELLOW)dev-backend-test$(NC)            Run unit tests"
	@echo "  $(YELLOW)dev-backend-test-e2e$(NC)        Run e2e tests (needs DB port-forward)"
	@echo ""
	@echo "$(GREEN)DEV - Mobile (Flutter):$(NC)"
	@echo "  $(YELLOW)dev-mobile-launch$(NC)           Launch Flutter app (interactive menu)"
	@echo "  $(YELLOW)dev-mobile-launch-desktop$(NC)   Launch on Linux desktop"
	@echo "  $(YELLOW)dev-mobile-launch-emulator$(NC)  Launch on Android emulator"
	@echo "  $(YELLOW)dev-mobile-launch-device$(NC)    Launch on Android device"
	@echo "  $(YELLOW)dev-mobile-widgetbook$(NC)       Launch Widgetbook (UI catalog)"
	@echo ""
	@echo "$(GREEN)DEV - Web Apps (managed by ArgoCD, manual fallback):$(NC)"
	@echo "  $(YELLOW)dev-superusers-start$(NC)        Start CRUD Superusers locally (dev)"
	@echo "  $(YELLOW)dev-superusers-stop$(NC)         Stop CRUD Superusers"
	@echo "  $(YELLOW)dev-superusers-deploy$(NC)       Deploy manually (fallback)"
	@echo "  $(YELLOW)dev-superusers-destroy$(NC)      Remove manually"
	@echo ""
	@echo "  $(YELLOW)dev-b2g-start$(NC)               Start B2G locally (dev)"
	@echo "  $(YELLOW)dev-b2g-stop$(NC)                Stop B2G"
	@echo "  $(YELLOW)dev-b2g-deploy$(NC)              Deploy manually (fallback)"
	@echo "  $(YELLOW)dev-b2g-destroy$(NC)             Remove manually"
	@echo ""
	@echo "$(GREEN)DEV - Utilities:$(NC)"
	@echo "  $(YELLOW)dev-infisical-sync$(NC)         Sync secrets from Infisical"
	@echo "  $(YELLOW)dev-infisical-sync-cli$(NC)     Sync secrets via CLI (no operator)"
	@echo ""
	@echo "$(GREEN)DEV - MCP Servers:$(NC)"
	@echo "  $(YELLOW)dev-mcp-start$(NC)              Start all MCP servers (context7, dart, graphql, etc.)"
	@echo "  $(YELLOW)dev-mcp-stop$(NC)               Stop all MCP servers"
	@echo "  $(YELLOW)dev-mcp-status$(NC)             Check MCP servers status"
	@echo ""
	@echo "$(GREEN)DEV - DevSecOps:$(NC)"
	@echo "  $(YELLOW)dev-security-scan$(NC)           Run all security scans"
	@echo "  $(YELLOW)dev-security-deps$(NC)           Scan dependencies"
	@echo "  $(YELLOW)dev-security-sast$(NC)           Static Application Security Testing"
	@echo "  $(YELLOW)dev-security-secrets$(NC)        Scan for secrets"
	@echo "  $(YELLOW)dev-security-container$(NC)      Scan container images"
	@echo "  $(YELLOW)dev-security-iac$(NC)            Scan Infrastructure as Code"
	@echo "  $(YELLOW)dev-security-fix$(NC)            Auto-fix vulnerabilities"
	@echo ""
	@echo "$(GREEN)QA (OVHCloud):$(NC)"
	@echo "  $(YELLOW)qa-terraform-deploy$(NC)         Deploy complete QA environment"
	@echo "  $(YELLOW)qa-terraform-destroy$(NC)        Destroy QA environment"
	@echo "  $(YELLOW)qa-verify$(NC)                   Verify QA deployment"
	@echo "  $(YELLOW)qa-gateway-deploy$(NC)           Deploy Gateway API to QA"
	@echo "  $(YELLOW)qa-postgres-deploy$(NC)          Deploy PostgreSQL to QA"
	@echo ""
	@echo "$(GREEN)STAGE (OVHCloud):$(NC)"
	@echo "  $(YELLOW)stage-terraform-deploy$(NC)      Deploy complete STAGING"
	@echo "  $(YELLOW)stage-terraform-destroy$(NC)     Destroy STAGING"
	@echo "  $(YELLOW)stage-verify$(NC)                Verify STAGING deployment"
	@echo "  $(YELLOW)stage-gateway-deploy$(NC)        Deploy Gateway API to STAGING"
	@echo "  $(YELLOW)stage-postgres-deploy$(NC)       Deploy PostgreSQL to STAGING"
	@echo ""
	@echo "$(GREEN)PROD (OVHCloud):$(NC)"
	@echo "  $(YELLOW)prod-deploy$(NC)                 Deploy to PROD (via GitHub Actions)"
	@echo "  $(YELLOW)prod-emergency-deploy$(NC)       Emergency PROD deploy"
	@echo ""
	@echo "$(GREEN)CI/CD:$(NC)"
	@echo "  $(YELLOW)ci-backend-build$(NC)            Build backend Docker image"
	@echo "  $(YELLOW)ci-backend-push$(NC)             Push backend image to GHCR"
	@echo "  $(YELLOW)ci-all-test$(NC)                 Run all tests"
	@echo ""

# ==========================================
# Setup
# ==========================================

setup: ## Setup local development environment
	@echo "$(BLUE)Setting up development environment...$(NC)"
	@chmod +x $(SCRIPTS_DIR)/lib/*.sh 2>/dev/null || true
	@chmod +x $(SCRIPTS_DIR)/*.sh
	@echo "$(GREEN)✓ Scripts are now executable$(NC)"
	@echo "$(BLUE)Checking prerequisites...$(NC)"
	@command -v kubectl >/dev/null 2>&1 || echo "$(YELLOW)⚠ kubectl not found$(NC)"
	@command -v tofu >/dev/null 2>&1 || echo "$(YELLOW)⚠ tofu not found$(NC)"
	@command -v minikube >/dev/null 2>&1 || echo "$(YELLOW)⚠ minikube not found$(NC)"
	@echo "$(GREEN)✓ Setup complete$(NC)"

# ==========================================
# DEV - Minikube
# ==========================================

dev-minikube-deploy: ## Create minikube cluster
	@echo "$(BLUE)Starting minikube...$(NC)"
	@minikube start --driver=podman --cpus=8 --memory=16384 --disk-size=50g
	@echo "$(GREEN)✓ Minikube started$(NC)"

dev-minikube-clear: ## Clear stuck namespaces (remove finalizers)
	@echo "$(BLUE)Clearing stuck namespaces...$(NC)"
	@for ns in $$(kubectl get ns -o jsonpath='{.items[*].metadata.name}'); do \
		if kubectl get ns $$ns -o jsonpath='{.status.phase}' 2>/dev/null | grep -q "Terminating"; then \
			echo "$(YELLOW)Clearing finalizers from namespace: $$ns$(NC)"; \
			kubectl patch ns $$ns --type merge -p '{"metadata":{"finalizers":[]}}' 2>/dev/null || true; \
		fi; \
	done
	@echo "$(GREEN)✓ Namespace cleanup complete$(NC)"

dev-minikube-destroy: ## Delete minikube cluster
	@echo "$(RED)Deleting minikube cluster...$(NC)"
	@minikube delete
	@echo "$(GREEN)✓ Minikube deleted$(NC)"

# ==========================================
# DEV - Terraform
# ==========================================

dev-terraform-deploy: ## Deploy all terraform resources (PostgreSQL + Gateway)
	@echo "$(BLUE)Deploying DEV terraform resources...$(NC)"
	@cd $(TF_DIR) && tofu init && tofu apply -auto-approve

dev-terraform-destroy: ## Destroy all terraform resources
	@echo "$(RED)Destroying DEV terraform resources...$(NC)"
	@cd $(TF_DIR) && tofu destroy

# ==========================================
# DEV - ArgoCD
# ==========================================

dev-argocd-deploy: ## Install ArgoCD + bootstrap all apps
	@echo "$(BLUE)Deploying ArgoCD...$(NC)"
	@$(SCRIPTS_DIR)/setup-argocd-dev.sh "$(REPO_URL)"
	@echo "$(BLUE)Building all images...$(NC)"
	@$(SCRIPTS_DIR)/build-backend-image-minikube.sh
	@$(SCRIPTS_DIR)/build-web-images-minikube.sh superusers
	@$(SCRIPTS_DIR)/build-web-images-minikube.sh b2g
	@echo "$(GREEN)✓ ArgoCD deployed with 3 applications$(NC)"

dev-argocd-destroy: ## Remove ArgoCD namespace
	@echo "$(RED)Destroying ArgoCD...$(NC)"
	@kubectl delete namespace argocd --ignore-not-found=true --wait=false
	@echo "$(GREEN)✓ ArgoCD namespace deleted$(NC)"

dev-argocd-status: ## Show ArgoCD applications
	@echo "$(BLUE)ArgoCD Applications:$(NC)"
	@kubectl get applications -n argocd 2>/dev/null || echo "$(YELLOW)No applications found or ArgoCD not installed$(NC)"
	@echo ""
	@echo "$(BLUE)ArgoCD Pods:$(NC)"
	@kubectl get pods -n argocd 2>/dev/null || echo "$(YELLOW)ArgoCD not installed$(NC)"

dev-argocd-password: ## Get ArgoCD admin password
	@echo "$(BLUE)ArgoCD Admin Password:$(NC)"
	@kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath='{.data.password}' 2>/dev/null | base64 -d && echo || echo "$(YELLOW)ArgoCD not installed$(NC)"

# ==========================================
# DEV - Gateway
# ==========================================

dev-gateway-deploy: ## Deploy Gateway API only
	@$(SCRIPTS_DIR)/deploy-gateway-api.sh dev --auto-approve

dev-gateway-start: ## Start port-forward to Gateway
	@echo "$(BLUE)Starting Gateway port-forward...$(NC)"
	@$(SCRIPTS_DIR)/dev-validate.sh || true
	@pkill -f "kubectl port-forward.*gateway" 2>/dev/null || true
	@kubectl port-forward -n nginx-gateway svc/gateway-nodeport 3001:80 > /dev/null 2>&1 &
	@sleep 2
	@echo "$(GREEN)✓ Gateway at http://localhost:3001$(NC)"
	@echo ""
	@echo "$(BLUE)Endpoints:$(NC)"
	@echo "  http://localhost:3001/admin/login     (CRUD Superusers)"
	@echo "  http://localhost:3001/b2g/login       (B2G)"
	@echo "  http://localhost:3001/graphql         (GraphQL API)"

dev-gateway-stop: ## Stop port-forward
	@echo "$(BLUE)Stopping port-forward...$(NC)"
	@pkill -f "kubectl port-forward" 2>/dev/null || true
	@echo "$(GREEN)✓ Port-forward stopped$(NC)"

# ==========================================
# DEV - PostgreSQL
# ==========================================

dev-postgres-deploy: ## Deploy PostgreSQL only
	@cd $(TF_DIR) && tofu init && tofu apply -target=module.postgres

dev-postgres-destroy: ## Destroy PostgreSQL
	@cd $(TF_DIR) && tofu destroy -target=module.postgres

dev-postgres-logs: ## Show PostgreSQL logs
	@kubectl logs -n altrupets-dev -l app=postgres --tail=100 -f

dev-postgres-port-forward: ## Port-forward PostgreSQL
	@pkill -f "kubectl port-forward.*5432" 2>/dev/null || true
	@kubectl port-forward -n altrupets-dev svc/postgres-dev-service 5432:5432

# ==========================================
# DEV - Backend
# ==========================================

dev-backend-test: ## Run backend unit tests
	@cd apps/backend && npm test

dev-backend-test-e2e: ## Run backend e2e tests
	@echo "$(BLUE)Running e2e tests...$(NC)"
	@cd apps/backend && npm run test:e2e

dev-backend-build: ## Build backend image
	@echo "$(BLUE)Building backend image...$(NC)"
	@$(SCRIPTS_DIR)/build-backend-image-minikube.sh
	@kubectl rollout restart deployment/backend -n altrupets-dev 2>/dev/null || true
	@kubectl rollout status deployment/backend -n altrupets-dev --timeout=120s 2>/dev/null || true
	@echo "$(GREEN)✓ Backend image built$(NC)"

dev-backend-start: ## Start backend in dev mode
	@./launch_backend_dev.sh

# ==========================================
# DEV - CRUD Superusers
# ==========================================

dev-superusers-start: ## Start CRUD Superusers locally
	@echo "$(BLUE)Starting CRUD Superusers...$(NC)"
	@pkill -f "kubectl port-forward.*backend-service" 2>/dev/null || true
	@kubectl port-forward -n altrupets-dev svc/backend-service 3001:3001 > /dev/null 2>&1 &
	@sleep 2
	@cd apps/web/crud-superusers && npm install && npm run dev &
	@echo "$(GREEN)✓ Running at http://localhost:5174/login$(NC)"

dev-superusers-stop: ## Stop CRUD Superusers
	@pkill -f "vite.*crud-superusers" 2>/dev/null || true
	@pkill -f "kubectl port-forward.*backend-service" 2>/dev/null || true
	@echo "$(GREEN)✓ CRUD Superusers stopped$(NC)"

dev-superusers-deploy: ## Deploy CRUD Superusers to minikube
	@$(SCRIPTS_DIR)/build-web-images-minikube.sh superusers
	@kubectl apply -k k8s/base/web-superusers --server-side -n altrupets-dev
	@kubectl rollout status deployment/web-superusers -n altrupets-dev --timeout=60s
	@echo "$(GREEN)✓ CRUD Superusers deployed$(NC)"

dev-superusers-destroy: ## Remove CRUD Superusers from minikube
	@kubectl delete -k k8s/base/web-superusers -n altrupets-dev --ignore-not-found=true
	@echo "$(GREEN)✓ CRUD Superusers removed$(NC)"

# ==========================================
# DEV - B2G
# ==========================================

dev-b2g-start: ## Start B2G locally
	@echo "$(BLUE)Starting B2G...$(NC)"
	@pkill -f "kubectl port-forward.*backend-service" 2>/dev/null || true
	@kubectl port-forward -n altrupets-dev svc/backend-service 3001:3001 > /dev/null 2>&1 &
	@sleep 2
	@cd apps/web/b2g && npm install && npm run dev &
	@echo "$(GREEN)✓ Running at http://localhost:5175/login$(NC)"

dev-b2g-stop: ## Stop B2G
	@pkill -f "vite.*b2g" 2>/dev/null || true
	@pkill -f "kubectl port-forward.*backend-service" 2>/dev/null || true
	@echo "$(GREEN)✓ B2G stopped$(NC)"

dev-b2g-deploy: ## Deploy B2G to minikube
	@$(SCRIPTS_DIR)/build-web-images-minikube.sh b2g
	@kubectl apply -k k8s/base/web-b2g --server-side -n altrupets-dev
	@kubectl rollout status deployment/web-b2g -n altrupets-dev --timeout=60s
	@echo "$(GREEN)✓ B2G deployed$(NC)"

dev-b2g-destroy: ## Remove B2G from minikube
	@kubectl delete -k k8s/base/web-b2g -n altrupets-dev --ignore-not-found=true
	@echo "$(GREEN)✓ B2G removed$(NC)"

# ==========================================
# DEV - Utilities
# ==========================================

dev-infisical-sync: ## Sync secrets from Infisical to Kubernetes
	@$(SCRIPTS_DIR)/infisical-sync.sh

dev-infisical-sync-cli: ## Sync secrets using Infisical CLI (no operator needed)
	@$(SCRIPTS_DIR)/infisical-sync.sh --cli

# ==========================================
# DEV - MCP Servers
# ==========================================

MCP_PID_DIR := /tmp/mcp-servers

dev-mcp-start: ## Start all MCP servers (context7, dart, graphql, mobile, stitch)
	@mkdir -p $(MCP_PID_DIR)
	@echo "$(BLUE)Starting MCP servers...$(NC)"
	@if [ -f $(MCP_PID_DIR)/context7.pid ] && kill -0 $$(cat $(MCP_PID_DIR)/context7.pid) 2>/dev/null; then \
		echo "$(YELLOW)context7 already running (PID: $$(cat $(MCP_PID_DIR)/context7.pid))$(NC)"; \
	else \
		CONTEXT7_API_KEY=$$(jq -r '.mcpServers.context7.env.CONTEXT7_API_KEY' mcp.json) \
			npx -y @upstash/context7-mcp & echo $$! > $(MCP_PID_DIR)/context7.pid; \
		echo "$(GREEN)✓ context7 started$(NC)"; \
	fi
	@if [ -f $(MCP_PID_DIR)/dart.pid ] && kill -0 $$(cat $(MCP_PID_DIR)/dart.pid) 2>/dev/null; then \
		echo "$(YELLOW)dart already running (PID: $$(cat $(MCP_PID_DIR)/dart.pid))$(NC)"; \
	else \
		dart mcp-server --force-roots-fallback & echo $$! > $(MCP_PID_DIR)/dart.pid; \
		echo "$(GREEN)✓ dart started$(NC)"; \
	fi
	@if [ -f $(MCP_PID_DIR)/graphql.pid ] && kill -0 $$(cat $(MCP_PID_DIR)/graphql.pid) 2>/dev/null; then \
		echo "$(YELLOW)graphql already running (PID: $$(cat $(MCP_PID_DIR)/graphql.pid))$(NC)"; \
	else \
		npx -y @apollographql/apollo-mcp-server & echo $$! > $(MCP_PID_DIR)/graphql.pid; \
		echo "$(GREEN)✓ graphql started$(NC)"; \
	fi
	@if [ -f $(MCP_PID_DIR)/mobile.pid ] && kill -0 $$(cat $(MCP_PID_DIR)/mobile.pid) 2>/dev/null; then \
		echo "$(YELLOW)mobile-mcp already running (PID: $$(cat $(MCP_PID_DIR)/mobile.pid))$(NC)"; \
	else \
		npx -y @mobilenext/mobile-mcp@latest & echo $$! > $(MCP_PID_DIR)/mobile.pid; \
		echo "$(GREEN)✓ mobile-mcp started$(NC)"; \
	fi
	@if [ -f $(MCP_PID_DIR)/stitch.pid ] && kill -0 $$(cat $(MCP_PID_DIR)/stitch.pid) 2>/dev/null; then \
		echo "$(YELLOW)stitch already running (PID: $$(cat $(MCP_PID_DIR)/stitch.pid))$(NC)"; \
	else \
		GOOGLE_CLOUD_PROJECT=$$(jq -r '.mcpServers.stitch.env.GOOGLE_CLOUD_PROJECT' mcp.json) \
			npx -y stitch-mcp & echo $$! > $(MCP_PID_DIR)/stitch.pid; \
		echo "$(GREEN)✓ stitch started$(NC)"; \
	fi
	@echo "$(GREEN)All MCP servers started. PIDs stored in $(MCP_PID_DIR)/$(NC)"

dev-mcp-stop: ## Stop all MCP servers
	@echo "$(BLUE)Stopping MCP servers...$(NC)"
	@for server in context7 dart graphql mobile stitch; do \
		if [ -f $(MCP_PID_DIR)/$$server.pid ]; then \
			kill $$(cat $(MCP_PID_DIR)/$$server.pid) 2>/dev/null || true; \
			rm -f $(MCP_PID_DIR)/$$server.pid; \
			echo "$(GREEN)✓ $$server stopped$(NC)"; \
		fi; \
	done
	@echo "$(GREEN)All MCP servers stopped$(NC)"

dev-mcp-status: ## Check MCP servers status
	@echo "$(BLUE)MCP Servers Status:$(NC)"
	@for server in context7 dart graphql mobile stitch; do \
		if [ -f $(MCP_PID_DIR)/$$server.pid ] && kill -0 $$(cat $(MCP_PID_DIR)/$$server.pid) 2>/dev/null; then \
			echo "  $(GREEN)● $$server$(NC) running (PID: $$(cat $(MCP_PID_DIR)/$$server.pid))"; \
		else \
			echo "  $(RED)○ $$server$(NC) stopped"; \
		fi; \
	done

# ==========================================
# DEV - DevSecOps
# ==========================================

dev-security-build: ## Build security scanner image in Minikube
	@$(SCRIPTS_DIR)/build-security-scanner.sh

dev-security-scan: dev-security-build ## Run all security scans (Kubernetes Job in Minikube)
	@echo "$(BLUE)Running security scans in Minikube...$(NC)"
	@$(SCRIPTS_DIR)/run-security-scan-minikube.sh all

dev-security-deps: dev-security-build ## Scan dependencies for vulnerabilities
	@$(SCRIPTS_DIR)/run-security-scan-minikube.sh deps

dev-security-sast: dev-security-build ## Static Application Security Testing
	@$(SCRIPTS_DIR)/run-security-scan-minikube.sh sast

dev-security-secrets: dev-security-build ## Scan for secrets in code
	@$(SCRIPTS_DIR)/run-security-scan-minikube.sh secrets

dev-security-container: dev-security-build ## Scan container images
	@$(SCRIPTS_DIR)/run-security-scan-minikube.sh container

dev-security-iac: dev-security-build ## Scan Infrastructure as Code
	@$(SCRIPTS_DIR)/run-security-scan-minikube.sh iac

dev-security-fix: dev-security-build ## Auto-fix vulnerabilities where possible
	@$(SCRIPTS_DIR)/run-security-scan-minikube.sh fix

# ==========================================
# QA Environment (OVHCloud)
# ==========================================

qa-terraform-deploy: qa-gateway-deploy qa-postgres-deploy ## Deploy complete QA environment
	@echo "$(GREEN)✓ QA deployed$(NC)"

qa-gateway-deploy: ## Deploy Gateway API to QA
	@$(SCRIPTS_DIR)/deploy-gateway-api.sh qa $(if $(AUTO_APPROVE),--auto-approve,)

qa-postgres-deploy: ## Deploy PostgreSQL to QA
	@$(SCRIPTS_DIR)/deploy-postgres.sh qa $(if $(AUTO_APPROVE),--auto-approve,) --storage 10Gi

qa-terraform-destroy: ## Destroy QA environment
	@echo "$(RED)Destroying QA...$(NC)"
	@cd $(TF_DIR) && tofu destroy -auto-approve 2>/dev/null || true

qa-verify: ## Verify QA deployment
	@$(SCRIPTS_DIR)/verify-deployment.sh qa

# ==========================================
# STAGE Environment (OVHCloud)
# ==========================================

stage-terraform-deploy: stage-gateway-deploy stage-postgres-deploy ## Deploy complete STAGING environment
	@echo "$(GREEN)✓ STAGING deployed$(NC)"

stage-gateway-deploy: ## Deploy Gateway API to STAGING
	@$(SCRIPTS_DIR)/deploy-gateway-api.sh staging $(if $(AUTO_APPROVE),--auto-approve,)

stage-postgres-deploy: ## Deploy PostgreSQL to STAGING
	@$(SCRIPTS_DIR)/deploy-postgres.sh staging $(if $(AUTO_APPROVE),--auto-approve,) --storage 20Gi

stage-terraform-destroy: ## Destroy STAGING environment
	@echo "$(RED)⚠️ WARNING: Destroying STAGING$(NC)"
	@read -p "Type 'staging' to confirm: " confirm && [ "$$confirm" = "staging" ] || exit 1
	@cd $(TF_DIR) && tofu destroy

stage-verify: ## Verify STAGING deployment
	@$(SCRIPTS_DIR)/verify-deployment.sh staging

# ==========================================
# PROD Environment (OVHCloud)
# ==========================================

prod-deploy: ## Deploy to PRODUCTION (via GitHub Actions)
	@echo "$(RED)Production deployments must be done via GitHub Actions:$(NC)"
	@echo "1. Create PR from main to production"
	@echo "2. Get 2 approvals"
	@echo "3. Merge to deploy"
	@exit 1

prod-emergency-deploy: ## Emergency PROD deploy (dangerous)
	@echo "$(RED)⚠️ EMERGENCY PRODUCTION DEPLOYMENT$(NC)"
	@read -p "Type 'EMERGENCY-PROD': " confirm && [ "$$confirm" = "EMERGENCY-PROD" ] || exit 1
	@echo "$(RED)Not implemented - Use GitHub Actions$(NC)"

# ==========================================
# CI/CD
# ==========================================

ci-backend-build: ## Build backend Docker image
	@echo "$(BLUE)Building backend image...$(NC)"
	@docker build -t $(GITHUB_REGISTRY)/backend:$(IMAGE_TAG) -f $(APPS_DIR)/backend/Dockerfile $(APPS_DIR)/backend
	@echo "$(GREEN)✓ Images built$(NC)"

ci-backend-push: ## Push backend image to GHCR
	@docker push $(GITHUB_REGISTRY)/backend:$(IMAGE_TAG)
	@docker push $(GITHUB_REGISTRY)/backend:latest
	@echo "$(GREEN)✓ Images pushed$(NC)"

ci-all-test: ## Run all tests
	@echo "$(GREEN)✓ Tests passed$(NC)"

.DEFAULT_GOAL := help


# ==========================================
# DEV - Mobile (Flutter)
# ==========================================

dev-mobile-launch: ## Launch Flutter app (interactive menu)
	@cd apps/mobile && ./launch_flutter_debug.sh

dev-mobile-launch-desktop: ## Launch Flutter on Linux desktop
	@cd apps/mobile && ./launch_flutter_debug.sh -l

dev-mobile-launch-emulator: ## Launch Flutter on Android emulator
	@cd apps/mobile && ./launch_flutter_debug.sh -e

dev-mobile-launch-device: ## Launch Flutter on Android device
	@cd apps/mobile && ./launch_flutter_debug.sh -d

dev-mobile-widgetbook: ## Launch Widgetbook (UI catalog)
	@cd apps/mobile && ./launch_flutter_debug.sh -w

# ==========================================
# Mobile - Analysis & Testing
# ==========================================

dev-mobile-analyze: ## Run dart analyze (Flutter SAST)
	@cd apps/mobile && ./flutter-sast.sh analyze

dev-mobile-test: ## Run Flutter unit tests
	@cd apps/mobile && ./flutter-sast.sh test

dev-mobile-test-coverage: ## Run Flutter tests with coverage
	@cd apps/mobile && ./flutter-sast.sh coverage

dev-mobile-lint: ## Run all Flutter linting
	@cd apps/mobile && ./flutter-sast.sh lint
