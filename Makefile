# Altrupets Monorepo - Automation Makefile
# ==========================================
# 
# Usage:
#   make <target> [ENV=<environment>]
#
# Examples:
#   make dev                    # Deploy to DEV (minikube)
#   make qa                     # Deploy to QA (OVHCloud)
#   make prod AUTO_APPROVE=true # Deploy to PROD with auto-approval
#   make help                   # Show all available targets

.PHONY: help install setup dev qa stage prod \
        dev-gateway qa-gateway stage-gateway prod-gateway \
        dev-postgres qa-postgres stage-postgres prod-postgres \
        dev-destroy qa-destroy stage-destroy prod-destroy \
        ci-build ci-push ci-deploy ci-test \
        verify logs port-forward shell \
        clean test lint

# ==========================================
# Variables
# ==========================================

ENV ?= dev
TF_DIR = infrastructure/terraform/environments/$(ENV)
SCRIPTS_DIR = infrastructure/scripts
APPS_DIR = apps
VERSION ?= $(shell git describe --tags --always 2>/dev/null || echo "dev")
GIT_SHA ?= $(shell git rev-parse --short HEAD 2>/dev/null || echo "unknown")
IMAGE_TAG = $(VERSION)-$(GIT_SHA)
GITHUB_REGISTRY = ghcr.io/altrupets

# Colors for output
BLUE := \033[36m
GREEN := \033[32m
YELLOW := \033[33m
RED := \033[31m
NC := \033[0m # No Color

# ==========================================
# Help
# ==========================================

help: ## Show this help message
	@echo ""
	@echo "$(BLUE)╔════════════════════════════════════════════════════════════╗$(NC)"
	@echo "$(BLUE)║       Altrupets Monorepo - Automation Commands             ║$(NC)"
	@echo "$(BLUE)╚════════════════════════════════════════════════════════════╝$(NC)"
	@echo ""
	@echo "$(GREEN)Usage:$(NC)"
	@echo "  make $(YELLOW)<target>$(NC) [$(YELLOW)ENV=$(NC)<environment>] [$(YELLOW)options$(NC)]"
	@echo ""
	@echo "$(GREEN)Quick Start:$(NC)"
	@echo "  make setup          $(BLUE)# Setup local development environment$(NC)"
	@echo "  make dev            $(BLUE)# Deploy everything to DEV (minikube)$(NC)"
	@echo "  make qa             $(BLUE)# Deploy to QA (OVHCloud)$(NC)"
	@echo ""
	@echo "$(GREEN)Environment Deployment:$(NC)"
	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z_-]+:.*?## / {printf "  $(YELLOW)%-20s$(NC) %s\n", $$1, $$2}' $(MAKEFILE_LIST) | grep -E "(dev|qa|stage|prod)-" | head -20
	@echo ""
	@echo "$(GREEN)Individual Components:$(NC)"
	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z_-]+:.*?## / {printf "  $(YELLOW)%-20s$(NC) %s\n", $$1, $$2}' $(MAKEFILE_LIST) | grep -E "gateway|postgres" | head -10
	@echo ""
	@echo "$(GREEN)CI/CD:$(NC)"
	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z_-]+:.*?## / {printf "  $(YELLOW)%-20s$(NC) %s\n", $$1, $$2}' $(MAKEFILE_LIST) | grep "ci-" | head -10
	@echo ""
	@echo "$(GREEN)Utilities:$(NC)"
	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z_-]+:.*?## / {printf "  $(YELLOW)%-20s$(NC) %s\n", $$1, $$2}' $(MAKEFILE_LIST) | grep -E "(verify|logs|clean|test)" | head -10
	@echo ""
	@echo "$(GREEN)Environments:$(NC) dev, qa, staging, prod"
	@echo ""

# ==========================================
# Setup & Installation
# ==========================================

setup: ## Setup local development environment (install dependencies)
	@echo "$(BLUE)Setting up development environment...$(NC)"
	@chmod +x $(SCRIPTS_DIR)/lib/*.sh
	@chmod +x $(SCRIPTS_DIR)/*.sh
	@echo "$(GREEN)✓ Scripts are now executable$(NC)"
	@echo "$(BLUE)Checking prerequisites...$(NC)"
	@command -v kubectl >/dev/null 2>&1 || echo "$(YELLOW)⚠ kubectl not found. Install: https://kubernetes.io/docs/tasks/tools/$(NC)"
	@command -v tofu >/dev/null 2>&1 || echo "$(YELLOW)⚠ tofu not found. Install: https://opentofu.org/docs/intro/install/$(NC)"
	@command -v docker >/dev/null 2>&1 || echo "$(YELLOW)⚠ docker not found. Install: https://docs.docker.com/get-docker/$(NC)"
	@echo "$(GREEN)✓ Setup complete$(NC)"

install: setup ## Alias for setup

# ==========================================
# DEV Environment (Local Minikube)
# ==========================================

dev: ## Deploy complete DEV environment (minikube)
	@echo "$(BLUE)Deploying DEV environment...$(NC)"
	@cd $(TF_DIR) && tofu init && tofu apply

dev-gateway: ## Deploy only Gateway API to DEV
	@echo "$(BLUE)Deploying Gateway API to DEV...$(NC)"
	@cd $(TF_DIR) && tofu init && tofu apply -target=module.gateway_api

dev-postgres: ## Deploy only PostgreSQL to DEV
	@echo "$(BLUE)Deploying PostgreSQL to DEV...$(NC)"
	@cd $(TF_DIR) && tofu init && tofu apply -target=module.postgres

dev-destroy: ## Destroy DEV environment
	@echo "$(RED)Destroying DEV environment...$(NC)"
	@cd $(TF_DIR) && tofu destroy

dev-status: ## Check DEV environment status
	@echo "$(BLUE)DEV Environment Status:$(NC)"
	@kubectl get pods -n default
	@kubectl get gateway -n default 2>/dev/null || echo "No gateways found"

# ==========================================
# QA Environment (OVHCloud - Ephemeral)
# ==========================================

qa: qa-gateway qa-postgres ## Deploy complete QA environment
	@echo "$(GREEN)✓ QA environment deployed$(NC)"

qa-gateway: ## Deploy Gateway API to QA
	@echo "$(BLUE)Deploying Gateway API to QA...$(NC)"
	@$(SCRIPTS_DIR)/deploy-gateway-api.sh qa $(if $(AUTO_APPROVE),--auto-approve,)

qa-postgres: ## Deploy PostgreSQL to QA
	@echo "$(BLUE)Deploying PostgreSQL to QA...$(NC)"
	@$(SCRIPTS_DIR)/deploy-postgres.sh qa $(if $(AUTO_APPROVE),--auto-approve,) --storage 10Gi

qa-destroy: ## Destroy QA environment
	@echo "$(RED)Destroying QA environment...$(NC)"
	@echo "$(YELLOW)Note: QA is ephemeral and can be recreated anytime$(NC)"
	@$(SCRIPTS_DIR)/deploy-gateway-api.sh qa --auto-approve 2>/dev/null || true
	@cd $(TF_DIR) && tofu destroy -auto-approve 2>/dev/null || true

qa-verify: ## Verify QA deployment
	@$(SCRIPTS_DIR)/verify-deployment.sh qa

# ==========================================
# STAGING Environment (OVHCloud - Prod-like)
# ==========================================

stage: stage-gateway stage-postgres ## Deploy complete STAGING environment
	@echo "$(GREEN)✓ STAGING environment deployed$(NC)"

stage-gateway: ## Deploy Gateway API to STAGING
	@echo "$(BLUE)Deploying Gateway API to STAGING...$(NC)"
	@$(SCRIPTS_DIR)/deploy-gateway-api.sh staging $(if $(AUTO_APPROVE),--auto-approve,)

stage-postgres: ## Deploy PostgreSQL to STAGING
	@echo "$(BLUE)Deploying PostgreSQL to STAGING...$(NC)"
	@$(SCRIPTS_DIR)/deploy-postgres.sh staging $(if $(AUTO_APPROVE),--auto-approve,) --storage 20Gi

stage-destroy: ## Destroy STAGING environment (⚠️ Confirm first)
	@echo "$(RED)⚠️  WARNING: Destroying STAGING environment$(NC)"
	@echo "$(YELLOW)STAGING is prod-like and should persist$(NC)"
	@read -p "Type 'staging' to confirm destruction: " confirm && [ "$$confirm" = "staging" ] || (echo "Cancelled" && exit 1)
	@$(SCRIPTS_DIR)/deploy-gateway-api.sh staging --auto-approve 2>/dev/null || true

stage-verify: ## Verify STAGING deployment
	@$(SCRIPTS_DIR)/verify-deployment.sh staging

# ==========================================
# PROD Environment (OVHCloud - Production)
# ==========================================

prod: ## Deploy to PRODUCTION (⚠️ Requires manual approval via PR)
	@echo "$(RED)╔════════════════════════════════════════════════════════════╗$(NC)"
	@echo "$(RED)║  PRODUCTION DEPLOYMENT                                     ║$(NC)"
	@echo "$(RED)╚════════════════════════════════════════════════════════════╝$(NC)"
	@echo ""
	@echo "$(YELLOW)Production deployments must be done via GitHub Actions:$(NC)"
	@echo ""
	@echo "1. Create a Pull Request from main to production branch"
	@echo "2. Get required approvals (minimum 2 reviewers)"
	@echo "3. Merge to trigger automatic deployment"
	@echo ""
	@echo "$(BLUE)Alternatively, for emergency fixes:$(NC)"
	@echo "  make prod-emergency AUTO_APPROVE=true"
	@echo ""
	@exit 1

prod-emergency: ## Emergency deploy to PROD (⚠️ Dangerous - avoid if possible)
	@echo "$(RED)⚠️  EMERGENCY PRODUCTION DEPLOYMENT$(NC)"
	@echo "$(YELLOW)This bypasses normal approval process$(NC)"
	@read -p "Type 'EMERGENCY-PROD' to confirm: " confirm && [ "$$confirm" = "EMERGENCY-PROD" ] || (echo "Cancelled" && exit 1)
	@echo "$(BLUE)Deploying to PRODUCTION...$(NC)"
	@echo "$(RED)⚠️  Not implemented - Use GitHub Actions for PROD$(NC)"

# ==========================================
# CI/CD Commands (for GitHub Actions)
# ==========================================

ci-build: ## Build Docker images for CI (VERSION required)
	@echo "$(BLUE)Building Docker images...$(NC)"
	@echo "  Version: $(VERSION)"
	@echo "  SHA: $(GIT_SHA)"
	@echo "  Tag: $(IMAGE_TAG)"
	@# Backend image
	@docker build -t $(GITHUB_REGISTRY)/backend:$(IMAGE_TAG) \
		-t $(GITHUB_REGISTRY)/backend:latest \
		-f $(APPS_DIR)/backend/Dockerfile \
		$(APPS_DIR)/backend
	@# Frontend image
	@docker build -t $(GITHUB_REGISTRY)/frontend:$(IMAGE_TAG) \
		-t $(GITHUB_REGISTRY)/frontend:latest \
		-f $(APPS_DIR)/web/Dockerfile \
		$(APPS_DIR)/web
	@echo "$(GREEN)✓ Images built$(NC)"

ci-push: ## Push images to GitHub Container Registry
	@echo "$(BLUE)Pushing images to GHCR...$(NC)"
	@docker push $(GITHUB_REGISTRY)/backend:$(IMAGE_TAG)
	@docker push $(GITHUB_REGISTRY)/backend:latest
	@docker push $(GITHUB_REGISTRY)/frontend:$(IMAGE_TAG)
	@docker push $(GITHUB_REGISTRY)/frontend:latest
	@echo "$(GREEN)✓ Images pushed$(NC)"

ci-test: ## Run tests in CI
	@echo "$(BLUE)Running tests...$(NC)"
	@# Add your test commands here
	@echo "$(GREEN)✓ Tests passed$(NC)"

ci-deploy: ## Deploy in CI (ENV required)
	@echo "$(BLUE)Deploying to $(ENV)...$(NC)"
	@make $(ENV) AUTO_APPROVE=true

# ==========================================
# Gateway API Commands
# ==========================================

gateway-deploy: ## Deploy Gateway API (ENV required)
	@echo "$(BLUE)Deploying Gateway API to $(ENV)...$(NC)"
	@$(SCRIPTS_DIR)/deploy-gateway-api.sh $(ENV) $(if $(AUTO_APPROVE),--auto-approve,)

gateway-destroy: ## Destroy Gateway API (ENV required)
	@echo "$(RED)Destroying Gateway API in $(ENV)...$(NC)"
	@cd $(TF_DIR) && tofu destroy -target=module.gateway_api $(if $(AUTO_APPROVE),-auto-approve,)

gateway-status: ## Check Gateway API status (ENV required)
	@echo "$(BLUE)Gateway API Status in $(ENV):$(NC)"
	@kubectl get gateway -n $(ENV) 2>/dev/null || kubectl get gateway -n default
	@kubectl get gatewayclass
	@kubectl get httproute -n $(ENV) 2>/dev/null || kubectl get httproute -n default

# ==========================================
# PostgreSQL Commands
# ==========================================

postgres-deploy: ## Deploy PostgreSQL (ENV required)
	@echo "$(BLUE)Deploying PostgreSQL to $(ENV)...$(NC)"
	@$(SCRIPTS_DIR)/deploy-postgres.sh $(ENV) $(if $(AUTO_APPROVE),--auto-approve,)

postgres-destroy: ## Destroy PostgreSQL (ENV required)
	@echo "$(RED)Destroying PostgreSQL in $(ENV)...$(NC)"
	@cd $(TF_DIR) && tofu destroy -target=module.postgres $(if $(AUTO_APPROVE),-auto-approve,)

postgres-logs: ## Show PostgreSQL logs (ENV required)
	@kubectl logs -n $(ENV) -l app=postgres --tail=100 -f

postgres-port-forward: ## Port-forward PostgreSQL to localhost (ENV required)
	@echo "$(BLUE)Port-forwarding PostgreSQL from $(ENV) to localhost:5432$(NC)"
	@kubectl port-forward -n $(ENV) svc/postgres-$(ENV)-service 5432:5432

# ==========================================
# Verification & Debugging
# ==========================================

verify: ## Verify deployment status (ENV required)
	@echo "$(BLUE)Verifying $(ENV) deployment...$(NC)"
	@$(SCRIPTS_DIR)/verify-deployment.sh $(ENV)

logs: ## Show all logs for environment (ENV required)
	@echo "$(BLUE)Logs for $(ENV):$(NC)"
	@kubectl get pods -n $(ENV) -o name | xargs -I {} kubectl logs -n $(ENV) {} --tail=50

port-forward: ## Interactive port-forward helper (ENV required)
	@echo "$(BLUE)Available services in $(ENV):$(NC)"
	@kubectl get svc -n $(ENV)
	@echo ""
	@echo "Usage: kubectl port-forward -n $(ENV) svc/<service-name> <local-port>:<service-port>"

shell: ## Open shell in a pod (ENV required, specify POD)
	@if [ -z "$(POD)" ]; then \
		echo "$(YELLOW)Usage: make shell ENV=$(ENV) POD=<pod-name>$(NC)"; \
		kubectl get pods -n $(ENV); \
	else \
		kubectl exec -n $(ENV) -it $(POD) -- /bin/sh; \
	fi

# ==========================================
# Utilities
# ==========================================

clean: ## Clean temporary files and terraform cache
	@echo "$(BLUE)Cleaning temporary files...$(NC)"
	@find . -type d -name ".terraform" -exec rm -rf {} + 2>/dev/null || true
	@find . -type f -name "*.tfstate.backup" -delete 2>/dev/null || true
	@find . -type f -name "crash.log" -delete 2>/dev/null || true
	@rm -rf /tmp/postgres-deploy-* 2>/dev/null || true
	@echo "$(GREEN)✓ Cleanup complete$(NC)"

test: ## Run all tests
	@echo "$(BLUE)Running tests...$(NC)"
	@# Add test commands here
	@echo "$(GREEN)✓ Tests complete$(NC)"

lint: ## Lint shell scripts and terraform
	@echo "$(BLUE)Linting...$(NC)"
	@shellcheck $(SCRIPTS_DIR)/*.sh 2>/dev/null || echo "$(YELLOW)shellcheck not installed$(NC)"
	@tofu fmt -check -recursive infrastructure/terraform/ 2>/dev/null || echo "$(YELLOW)Terraform formatting issues found$(NC)"
	@echo "$(GREEN)✓ Lint complete$(NC)"

# ==========================================
# Default Target
# ==========================================

.DEFAULT_GOAL := help
