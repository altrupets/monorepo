# Changelog - Version 0.2.0

## [0.2.0] - 2026-02-16

### Added
- [x] Despliegue de PostgreSQL en Minikube con Terraform/OpenTofu (`infrastructure/terraform/...`).
- [x] Script `infrastructure/scripts/deploy-postgres-dev.sh` con:
  - Inicio automático de Minikube.
  - Soporte y diagnóstico para Podman rootless.
  - Prompt de password (UI con `zenity`/`kdialog`, fallback CLI).
  - Persistencia local segura del secret en `infrastructure/terraform/environments/dev/.env`.
- [x] Flujo GitOps base con ArgoCD para backend en Minikube:
  - Kustomize base/overlay (`k8s/base/backend`, `k8s/overlays/dev/backend`).
  - Proyecto y aplicación ArgoCD (`k8s/argocd/...`).
  - Scripts:
    - `infrastructure/scripts/build-backend-image-minikube.sh`
    - `infrastructure/scripts/setup-argocd-dev.sh`
- [x] Backend:
  - Query GraphQL `users` y `user(id)`.
  - Dockerfile en `apps/backend/Dockerfile`.
- [x] Mobile:
  - Login con GraphQL.
  - Edición de perfil y mutación `updateUserProfile`.
- [x] Web:
  - CRUD básico de usuarios con React + Vite.

### Changed
- [x] Backend movido de `apps/backend/user-management-service/` a `apps/backend/`.
- [x] Nombre del package backend actualizado a `altrupets-backend`.
- [x] `apps/backend/src/app.module.ts`:
  - Cache con fallback a memoria cuando `REDIS_URL` no está definido.
  - `autoSchemaFile` ajustado a `schema.gql` para runtime en contenedor.
- [x] Host DB para backend en K8s actualizado a:
  - `postgres-dev-service.default.svc.cluster.local`
- [x] `.gitignore` endurecido para estado/vars de Terraform/OpenTofu:
  - `*.tfvars`, `*.tfstate*`, `.terraform/`, `.terraform.lock.hcl`.

### Fixed
- [x] Error de arranque Minikube por driver Podman no saludable (`DRV_NOT_HEALTHY`) con mensajes de remediación claros.
- [x] Flujo de configuración que antes exigía editar manualmente `terraform.tfvars`.

### Deprecated
- [ ] Flujo local “backend fuera de Kubernetes” como camino principal de pruebas E2E.

### Removed
- [x] Dependencia del folder legado `apps/backend/user-management-service/` para desarrollo activo.

### Security
- [x] Secret de PostgreSQL fuera de `terraform.tfvars` por defecto.
- [x] Manejo de `.env` local con permisos restrictivos (`chmod 600`) en scripts.

---

## Estado Actual (Operativo)

### Infraestructura
- PostgreSQL en Minikube: **listo**.
- Namespace app: `altrupets-dev`.
- Backend en K8s vía ArgoCD: **listo para bootstrap/sync**.

### Aplicaciones
- Backend GraphQL/Nest: **listo** (despliegue K8s preparado).
- Mobile (Flutter): **login + edición de perfil listos**.
- Web CRUD: **listo**.

---

## Runbook Rápido (Dev en Minikube)

1. Desplegar PostgreSQL:
```bash
./infrastructure/scripts/deploy-postgres-dev.sh
```

2. Construir imagen backend en runtime de Minikube:
```bash
./infrastructure/scripts/build-backend-image-minikube.sh
```

3. Bootstrap ArgoCD + aplicación backend:
```bash
REPO_URL=https://github.com/<org>/<repo>.git ./infrastructure/scripts/setup-argocd-dev.sh
```

4. Verificar estado:
```bash
kubectl -n argocd get applications
kubectl -n altrupets-dev get pods,svc
```

5. Exponer backend para Flutter desktop:
```bash
kubectl -n altrupets-dev port-forward svc/backend-service 3001:3001
```

6. Ejecutar app Flutter Linux:
```bash
./launch_debug.sh --linux
```

---

## Pendientes / Nice-to-Have
- [ ] Argo Rollouts (Blue/Green o Canary) para reemplazar `RollingUpdate` estándar.
- [ ] Protección de queries admin (`users`, `user`) con guardas y roles en producción.
- [ ] Migraciones DB formales (reemplazar `synchronize: true` fuera de dev).

---

## Referencias
- Skill de versionado: `skills/versioning-management/SKILL.md`
- Skill ArgoCD: `skills/cicd/argocd/SKILL.md`
- Guía K8s local: `k8s/README.md`
