# PASO 11: Mejores Practicas y Preparacion Cloud

## 11.1 Infisical para Secrets en Prod

Crear `infrastructure/infisical/infisical-agent-secret.yaml`:

```yaml
apiVersion: secrets.infisical.com/v1alpha1
kind: InfisicalSecret
metadata:
  name: infisical-agent-secret
  namespace: altrupets-dev
spec:
  hostAPI: https://app.infisical.com/api
  authentication:
    universalAuth:
      secretsScope:
        projectSlug: altrupets-monorepo
        envSlug: dev
        secretsPath: /agent
  managedKubeSecretReferences:
    - secretName: agent-secret
      secretNamespace: altrupets-dev
      creationPolicy: Orphan
```

## 11.2 Helm para FalkorDB en Prod

```bash
# En QA/STAGE/PROD, reemplazar el manifiesto base con:
helm repo add falkordb https://falkordb.github.io/charts
helm install falkordb falkordb/falkordb \
  --namespace altrupets-{env} \
  --set auth.password=${FALKORDB_PASSWORD} \
  --set persistence.size=10Gi \
  --set resources.requests.memory=2Gi \
  --set resources.limits.memory=4Gi \
  --set replication.enabled=true
```

## 11.3 ArgoCD para Deploys Independientes

Ya configurado con app-of-apps pattern. Agregar al sync del Makefile:

```makefile
# En dev-argocd-push-and-deploy, agregar:
@argocd app sync altrupets-agent-dev --grpc-web 2>/dev/null || true

# En dev-argocd-sync-local, agregar:
@argocd app sync altrupets-agent-dev --local ./k8s/overlays/dev/agent --grpc-web
```

## 11.4 HPA para Agent en Prod

```yaml
# k8s/base/agent/hpa.yaml — solo para QA/STAGE/PROD
apiVersion: autoscaling/v2
kind: HorizontalPodAutoscaler
metadata:
  name: agent-hpa
spec:
  scaleTargetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: agent
  minReplicas: 2
  maxReplicas: 10
  metrics:
    - type: Resource
      resource:
        name: cpu
        target:
          type: Utilization
          averageUtilization: 70
    - type: Resource
      resource:
        name: memory
        target:
          type: Utilization
          averageUtilization: 80
```

## 11.5 Langfuse Dashboard

- **Dev local:** Usar [Langfuse Cloud](https://cloud.langfuse.com) (free tier).
- **Self-hosted en prod:**
  ```bash
  helm repo add langfuse https://langfuse.github.io/langfuse-k8s
  helm install langfuse langfuse/langfuse --namespace monitoring
  ```

## 11.6 CI/CD — Agregar al Workflow

En `.github/workflows/build-images.yml`, agregar job para agent:

```yaml
  build-agent:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - name: Build agent image
        run: |
          docker build -t ghcr.io/altrupets/agent:${{ github.sha }} \
            -f apps/agent/Dockerfile apps/agent
      - name: Push to GHCR
        run: docker push ghcr.io/altrupets/agent:${{ github.sha }}
```

## Estructura Final de Archivos Nuevos

```
altrupets-monorepo/
├── package.json                          <- NUEVO (root workspace)
├── pnpm-workspace.yaml                   <- NUEVO
├── turbo.json                            <- NUEVO
├── .npmrc                                <- NUEVO (root)
├── Makefile                              <- MODIFICADO (append agent targets)
├── apps/
│   ├── agent/                            <- NUEVO (todo el directorio)
│   │   ├── package.json
│   │   ├── tsconfig.json
│   │   ├── nest-cli.json
│   │   ├── Dockerfile
│   │   ├── .dockerignore
│   │   └── src/
│   │       ├── main.ts
│   │       ├── app.module.ts
│   │       ├── agent/
│   │       │   ├── agent.module.ts
│   │       │   ├── agent.service.ts
│   │       │   ├── agent.resolver.ts
│   │       │   ├── dto/rescuer-recommendation.dto.ts
│   │       │   └── guards/jwt-auth.guard.ts
│   │       ├── graph/
│   │       │   └── rescuer-graph.service.ts
│   │       ├── memory/
│   │       │   ├── memory.module.ts
│   │       │   └── memory.service.ts
│   │       ├── observability/
│   │       │   ├── observability.module.ts
│   │       │   └── langfuse.service.ts
│   │       ├── health/
│   │       │   ├── health.module.ts
│   │       │   └── health.controller.ts
│   │       └── config/
│   │           └── env.ts
│   └── backend/
│       └── package.json                  <- MODIFICADO (name -> @altrupets/backend)
├── infrastructure/
│   ├── scripts/
│   │   └── build-agent-image-minikube.sh <- NUEVO
│   └── infisical/
│       └── infisical-agent-secret.yaml   <- NUEVO
├── k8s/
│   ├── base/
│   │   ├── agent/                        <- NUEVO
│   │   │   ├── deployment.yaml
│   │   │   ├── service.yaml
│   │   │   ├── configmap.yaml
│   │   │   ├── secret.yaml
│   │   │   ├── httproute.yaml
│   │   │   └── kustomization.yaml
│   │   └── falkordb/                     <- NUEVO
│   │       ├── deployment.yaml
│   │       ├── service.yaml
│   │       ├── pvc.yaml
│   │       ├── secret.yaml
│   │       └── kustomization.yaml
│   ├── overlays/dev/
│   │   ├── agent/                        <- NUEVO
│   │   │   ├── patch-deployment.yaml
│   │   │   └── kustomization.yaml
│   │   └── falkordb/                     <- NUEVO
│   │       └── kustomization.yaml
│   └── argocd/applications/
│       └── agent-dev.yaml                <- NUEVO
```

## Quick Reference — Comandos Diarios

```bash
# Setup inicial (una vez)
make setup && make dev-minikube-deploy && make dev-terraform-deploy
pnpm install

# Build y deploy agent + FalkorDB
make dev-agent-build
make dev-agent-deploy

# Dev hot-reload (sin k8s)
make dev-falkordb-port-forward &
make dev-agent-start

# Turbo paralelo
pnpm turbo run dev --filter=@altrupets/backend --filter=@altrupets/agent

# Logs
make dev-agent-logs
make dev-falkordb-logs

# GraphQL playground
make dev-agent-port-forward  # http://localhost:4000/graphql
```
