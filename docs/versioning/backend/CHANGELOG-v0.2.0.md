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

## Implementación v0.2.1 - Completado ✅

### Argo Rollouts (Blue/Green Deployment)
- **Archivos creados**:
  - `k8s/base/backend/rollout.yaml` - Rollout con estrategia Blue/Green
  - `k8s/base/backend/service-preview.yaml` - Servicio para preview de nueva versión
  - `k8s/base/backend/pvc.yaml` - PVC para persistencia de avatars
- **Características**:
  - 2 réplicas para alta disponibilidad
  - Auto-promoción después de 30 segundos
  - Servicio preview para testing antes de switch
  - Estrategia Canary comentada como alternativa

### Protección de Queries Admin
- **Estado**: ✅ Ya implementado en `users.resolver.ts`
- **Queries protegidas**: `users`, `user`, `createUser`, `updateUser`, `deleteUser`
- **Roles requeridos**: `SUPER_USER`, `USER_ADMIN`, `LEGAL_REPRESENTATIVE`
- **Implementación**:
  - `@UseGuards(JwtAuthGuard, RolesGuard)`
  - `@Roles(...USER_ADMIN_ROLES)`
  - Verificación adicional: solo `SUPER_USER` puede gestionar otros `SUPER_USER`

### Migraciones DB Formales
- **Cambios en `app.module.ts`**:
  - `synchronize: false` en producción (`NODE_ENV=production`)
  - `migrationsRun: true` para ejecución automática
  - Configuración de path de migraciones
- **Scripts agregados a `package.json`**:
  - `migration:generate` - Generar nuevas migraciones
  - `migration:run` - Ejecutar migraciones pendientes
  - `migration:revert` - Revertir última migración
- **Archivos creados**:
  - `src/data-source.ts` - Configuración TypeORM CLI
  - `src/migrations/1771407449000-MigrateAvatarToUrl.ts` - Migración de avatars

### Migración de Avatars a Object Storage
- **Entidad `User` actualizada**:
  - Nuevo campo: `avatarUrl` (string, nullable)
  - Nuevo campo: `avatarStorageProvider` (string, default: 'local')
  - Campos legacy mantenidos para compatibilidad: `avatarImage`, `avatarBase64`
- **Servicio creado**: `AvatarStorageService`
  - Soporte para almacenamiento local (DEV) y S3 (PROD)
  - Configuración vía variables de entorno:
    - `AVATAR_STORAGE_TYPE`: 'local' | 's3'
    - `S3_ENDPOINT`: Endpoint S3/MinIO
    - `S3_BUCKET_NAME`: Nombre del bucket
- **Actualización de resolver**: `updateUserProfile` ahora usa el servicio de almacenamiento
- **Infraestructura**:
  - PVC para persistencia de avatars en DEV
  - Volumen montado en `/app/uploads/avatars`
  - ConfigMap actualizado con variables de almacenamiento

### Variables de Entorno Agregadas
```bash
# Almacenamiento de avatars
AVATAR_STORAGE_TYPE=local  # 'local' para DEV, 's3' para PROD
S3_ENDPOINT=               # URL de S3/MinIO (solo PROD)
S3_BUCKET_NAME=            # Nombre del bucket (solo PROD)

# Database migrations (ya existía)
NODE_ENV=development       # 'production' para deshabilitar synchronize
```

## Referencias
- Skill de versionado: `skills/versioning-management/SKILL.md`
- Skill ArgoCD: `skills/cicd/argocd/SKILL.md`
- Guía K8s local: `k8s/README.md`
- Argo Rollouts: https://argoproj.github.io/argo-rollouts/
