# Changelog - Infrastructure v0.3.0

## [v0.3.0] - 2025-02-18

### Added

#### Infisical Integration for Secrets Management
- Integrated Infisical Kubernetes Secrets Operator for centralized secrets management
- Created Machine Identity `minikube-dev` with Viewer role for dev environment
- Configured `InfisicalSecret` CRD to sync secrets from Infisical to Kubernetes
- Secrets are now managed at https://app.infisical.com (project: `altrupets-monorepo`)

#### Single Secret Architecture
- Consolidated `postgres-dev-secret` and `backend-secret` into single `backend-secret`
- `backend-secret` now contains all required secrets:
  - `DB_USERNAME` - PostgreSQL username
  - `DB_PASSWORD` - PostgreSQL password
  - `DB_NAME` - PostgreSQL database name
  - `JWT_SECRET` - JWT signing secret
  - `SEED_ADMIN_USERNAME` - Admin seed username
  - `SEED_ADMIN_PASSWORD` - Admin seed password
  - `ENV_NAME` - Environment name

### Changed

#### Minikube Resource Configuration
- Updated CPU allocation from 4 to 8 cores
- Updated memory allocation from 8GB to 16GB
- Updated disk size from 20GB to 50GB
- Files updated:
  - `Makefile`
  - `scripts/minikube-setup.sh`

#### PostgreSQL Configuration
- Migrated from `default` namespace to `altrupets-dev` namespace
- Increased storage size from 10Gi to 20Gi
- Now references `backend-secret` instead of `postgres-dev-secret`
- Updated files:
  - `infrastructure/terraform/environments/dev/main.tf`
  - `infrastructure/terraform/modules/database/postgres-minikube/main.tf`
  - `infrastructure/terraform/modules/database/postgres-minikube/variables.tf`

#### Backend Configuration
- Updated `DB_HOST` from `postgres-dev-service.default.svc.cluster.local` to `postgres-dev-service.altrupets-dev.svc.cluster.local`
- File: `k8s/base/backend/configmap.yaml`

#### Database Name Standardization
- Changed default database name from `altrupets_user_management` to `altrupets_dev_database`
- Files updated:
  - `infrastructure/terraform/modules/database/postgres-minikube/variables.tf`
  - `infrastructure/terraform/environments/dev/variables.tf`
  - `infrastructure/terraform/environments/dev/terraform.tfvars.example`
  - `infrastructure/terraform/README.md`
  - `apps/mobile/launch_flutter_debug.sh`

### Removed

#### Duplicate Secret Management
- Removed `postgres-dev-secret` InfisicalSecret CRD
- Removed redundant secret creation in `dev-validate.sh`
- Removed `postgres-dev-secret` references from:
  - `infrastructure/infisical/infisical-secrets.yaml`
  - `infrastructure/scripts/dev-validate.sh`
  - `apps/mobile/launch_flutter_debug.sh`

### Fixed

#### Terraform State Management
- Fixed terraform state import for existing resources after cluster recreation
- Added proper resource imports for:
  - `module.postgres.kubernetes_stateful_set.postgres`
  - `module.gateway_api.kubernetes_namespace.app_namespace`
  - `module.gateway_api.helm_release.nginx_gateway_fabric[0]`

#### Script Updates
- Updated `setup-argocd-dev.sh` to read secrets from Infisical-managed `backend-secret`
- Updated `dev-validate.sh` to skip secret sync when Infisical is managing secrets
- Simplified `apps/mobile/launch_flutter_debug.sh` secret synchronization logic

### Configuration Files

#### New Files
- `infrastructure/infisical/infisical-secrets.yaml` - InfisicalSecret CRD configuration

#### Modified Files
- `Makefile` - Updated minikube resources, auto-approve for terraform
- `scripts/minikube-setup.sh` - Updated minikube resources
- `infrastructure/infisical/infisical-secrets.yaml` - Single secret architecture
- `infrastructure/terraform/environments/dev/main.tf` - Namespace and secret references
- `infrastructure/terraform/modules/database/postgres-minikube/main.tf` - Secret reference
- `infrastructure/terraform/modules/database/postgres-minikube/variables.tf` - Default secret name
- `infrastructure/scripts/setup-argocd-dev.sh` - Infisical integration
- `infrastructure/scripts/dev-validate.sh` - Infisical detection
- `k8s/base/backend/configmap.yaml` - Updated DB_HOST
- `apps/mobile/launch_flutter_debug.sh` - Simplified secret handling

### Breaking Changes

1. **Namespace Migration**: PostgreSQL moved from `default` to `altrupets-dev` namespace
   - Requires updating any external connections to use new service endpoint

2. **Secret Consolidation**: `postgres-dev-secret` no longer exists
   - All applications should reference `backend-secret` for database credentials

### Migration Guide

If you have an existing setup:

1. **Recreate Minikube cluster** (required for new resource limits):
   ```bash
   minikube delete
   make dev-minikube-deploy
   ```

2. **Configure Infisical credentials**:
   ```bash
   kubectl create secret generic infisical-operator-credentials \
     --namespace infisical-operator-system \
     --from-literal=clientId=<your-client-id> \
     --from-literal=clientSecret=<your-client-secret>
   ```

3. **Deploy infrastructure**:
   ```bash
   make dev-terraform-deploy
   make dev-argocd-deploy
   make dev-gateway-start
   ```

### Dependencies

- Infisical Secrets Operator (installed via Helm)
- OpenTofu/Terraform
- Minikube with Podman driver
- ArgoCD

### Verification

After deployment, verify:

```bash
# Check Infisical secrets are synced
kubectl get infisicalsecret -n altrupets-dev

# Check backend-secret exists
kubectl get secret backend-secret -n altrupets-dev -o jsonpath='{.data}' | jq 'keys'

# Check PostgreSQL is running
kubectl get pods -n altrupets-dev -l app=postgres

# Check backend is healthy
kubectl get pods -n altrupets-dev -l app=backend
```
