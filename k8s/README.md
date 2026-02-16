# Kubernetes + ArgoCD (Minikube)

Este directorio contiene el despliegue GitOps del backend para entorno `dev` en Minikube.

## Estructura

- `k8s/base/backend`: recursos base del backend (Deployment/Service/ConfigMap).
- `k8s/overlays/dev/backend`: overlay de desarrollo para namespace `altrupets-dev`.
- `k8s/argocd`: project y applications de ArgoCD.

## Requisitos

- Minikube corriendo
- PostgreSQL desplegado (`./infrastructure/scripts/deploy-postgres-dev.sh`)
- Repositorio publicado en Git remoto (ArgoCD no sincroniza desde tu disco local)

## Flujo recomendado

1. Crear/actualizar imagen del backend dentro de Minikube:

```bash
./infrastructure/scripts/build-backend-image-minikube.sh
```

2. Instalar y bootstrap de ArgoCD + Application:

```bash
REPO_URL=https://github.com/<org>/<repo>.git ./infrastructure/scripts/setup-argocd-dev.sh
```

3. Verificar sincronización:

```bash
kubectl -n argocd get applications
kubectl -n altrupets-dev get pods,svc
```

4. Probar backend:

```bash
kubectl -n altrupets-dev port-forward svc/backend-service 3001:3001
curl http://localhost:3001/health
```

## Secret local

- El secret de BD se lee de `infrastructure/terraform/environments/dev/.env`.
- `setup-argocd-dev.sh` crea/actualiza `backend-secret` en `altrupets-dev`.
- El secret **no** se comitea al repo.
