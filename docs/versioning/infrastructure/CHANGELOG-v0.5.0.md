# Changelog - Infrastructure v0.5.0

## [v0.5.0] - 2026-02-19

### Added

#### MCP Server Management
- **Makefile targets** para gestión de MCP servers:
  - `dev-mcp-start`: Inicia todos los MCP servers (context7, dart, graphql, mobile, stitch)
  - `dev-mcp-stop`: Detiene todos los MCP servers
  - `dev-mcp-status`: Muestra estado de los MCP servers
- **PID management**: PIDs almacenados en `/tmp/mcp-servers/` para control de procesos
- **Soporte para**:
  - Context7 (documentación técnica)
  - Dart/Flutter MCP
  - Apollo GraphQL MCP
  - Mobile MCP (dispositivos móviles)
  - Stitch MCP (UI generation)

#### Gateway Deployment Improvements
- **Detección automática de recreación**: `dev-gateway-deploy` detecta cuando el Gateway manifest necesita recreación
- **Destrucción automática**: Si el plan indica "forces replacement", destruye el manifest antes de aplicar
- **Manejo de estado desincronizado**: Resuelve errores de "inconsistent result" del provider kubernetes

### Fixed

#### Gateway API Terraform Module
- **Conditional listeners**: Corregido error al usar condicionales con arrays de diferente longitud
- **Template-based manifest**: Migrado de HCL inline a `jsondecode(templatefile())` para mayor flexibilidad
- **Nuevo template**: `infrastructure/terraform/modules/kubernetes/gateway-api/templates/gateway.json.tpl`

#### Gateway Port-forward
- **Servicio correcto**: `dev-gateway-start` ahora apunta a `altrupets-dev/dev-gateway-nginx` (antes `nginx-gateway/gateway-nodeport`)

### Changed

#### Kustomize Overlays Unification
- **Targets `-tf-deploy` usan overlays**: Manual y GitOps ahora usan los mismos paths
  - `dev-backend-tf-deploy` → `k8s/overlays/dev/backend`
  - `dev-superusers-tf-deploy` → `k8s/overlays/dev/web-superusers`
  - `dev-b2g-tf-deploy` → `k8s/overlays/dev/web-b2g`
- **Consistencia garantizada**: Ambos flujos aplican el mismo namespace y patches

#### ArgoCD Applications
- **repoURL corregido**: Actualizado de `your-org/altrupets-monorepo` a `altrupets/monorepo`
- **Archivos afectados**:
  - `k8s/argocd/applications/backend-dev.yaml`
  - `k8s/argocd/applications/web-superusers-dev.yaml`
  - `k8s/argocd/applications/web-b2g-dev.yaml`

#### deploy-gateway-api.sh
- **Dev environment support**: Ahora soporta ambiente `dev` (antes solo QA/Staging)
- **Force recreate flag**: Nuevo parámetro `--force-recreate` para forzar recreación del Gateway
- **Environment variable**: `FORCE_RECREATE` para control programático

### Technical Details

#### Kustomize Path Structure
```
k8s/
├── base/                          # Manifiestos base (sin namespace)
│   ├── backend/
│   ├── web-superusers/
│   └── web-b2g/
│
├── overlays/
│   └── dev/
│       ├── backend/
│       │   ├── kustomization.yaml   # namespace + patches
│       │   ├── namespace.yaml
│       │   └── patch-deployment.yaml
│       ├── web-superusers/
│       │   └── kustomization.yaml   # namespace
│       └── web-b2g/
│           └── kustomization.yaml   # namespace
│
└── argocd/
    └── applications/
        ├── backend-dev.yaml         # path: k8s/overlays/dev/backend
        ├── web-superusers-dev.yaml  # path: k8s/overlays/dev/web-superusers
        └── web-b2g-dev.yaml         # path: k8s/overlays/dev/web-b2g
```

#### MCP Servers Configuration
```json
// mcp.json
{
  "mcpServers": {
    "dart": { "command": "dart", "args": ["mcp-server", "--force-roots-fallback"] },
    "graphql": { "command": "npx", "args": ["-y", "@apollographql/apollo-mcp-server"] },
    "context7": { "command": "npx", "args": ["-y", "@upstash/context7-mcp"] },
    "mobile-mcp": { "command": "npx", "args": ["-y", "@mobilenext/mobile-mcp@latest"] },
    "stitch": { "command": "npx", "args": ["-y", "stitch-mcp"] }
  }
}
```

#### Gateway Template Structure
```json
{
  "apiVersion": "gateway.networking.k8s.io/v1",
  "kind": "Gateway",
  "spec": {
    "listeners": [
      { "name": "http", "protocol": "HTTP", "port": 80 }
      %{ if enable_https }
      ,{ "name": "https", "protocol": "HTTPS", "port": 443, "tls": {...} }
      %{ endif }
    ]
  }
}
```

### Files Modified

| Archivo | Cambio |
|---------|--------|
| `Makefile` | Targets `-tf-deploy` usan overlays, nuevos targets `dev-mcp-*` |
| `k8s/argocd/applications/*.yaml` | repoURL corregido a `altrupets/monorepo` |
| `infrastructure/terraform/modules/kubernetes/gateway-api/main.tf` | Migrado a template JSON |
| `infrastructure/terraform/modules/kubernetes/gateway-api/templates/gateway.json.tpl` | Nuevo template |
| `infrastructure/scripts/deploy-gateway-api.sh` | Soporte para dev y force-recreate |
| `mcp.json` | Configuración de MCP servers |

### Deployment Flows

#### Manual (sin ArgoCD)
```bash
make setup && make dev-minikube-deploy && make dev-terraform-deploy && \
make dev-images-build && make dev-backend-tf-deploy && \
make dev-superusers-tf-deploy && make dev-b2g-tf-deploy && make dev-gateway-start
```

#### GitOps (con ArgoCD)
```bash
make setup && make dev-minikube-deploy && make dev-terraform-deploy && \
make dev-images-build && make dev-argocd-deploy && make dev-gateway-start
```

### References

- [Kubernetes Gateway API](https://gateway-api.sigs.k8s.io/)
- [Context7 MCP](https://github.com/upstash/context7-mcp)
- [Terraform templatefile function](https://developer.hashicorp.com/terraform/language/functions/templatefile)
- [Kustomize Overlays](https://kubectl.docs.kubernetes.io/guides/introduction/kustomize/)
