# Changelog - Infrastructure v0.4.0

## [v0.4.0] - 2025-02-18

### Added

#### Estrategia de Despliegue: Kustomize para Apps, Helm para Infraestructura

Se define la estrategia de gestión de configuración para separar responsabilidades:

| Componente | Herramienta | Razón |
|------------|-------------|-------|
| Backend, Web apps | Kustomize | Simple, parches entre environments |
| ArgoCD Applications | Kustomize | Solo cambia namespace |
| Gateway API, Istio | Helm | Dependencies, versioning |
| Infisical Operator | Helm | Chart oficial disponible |

#### Ventajas de Kustomize para Apps

- **Declarativo**: Sin templating complejo, solo overlays
- **GitOps-friendly**: Integración nativa con ArgoCD
- **Auditable**: Cambios claros entre environments
- **Ya implementado**: Patrón `base/overlays` existente

#### Ventajas de Helm para Infraestructura

- **Gestión de releases**: Versionado, rollback
- **Dependencies**: Charts dependientes (ej: gateway-api depende de CRDs)
- **Charts oficiales**: Infisical, NGINX Gateway Fabric, Istio
- **Values**: Configuración compleja condicional

### Changed

#### Secrets Management: Infisical (Cloud-Agnostic)

Se actualiza la estrategia de secrets para usar Infisical en todos los ambientes:

- **DEV**: Minikube + Infisical
- **QA**: OVHCloud + Infisical
- **STAGING**: OVHCloud + Infisical
- **PROD**: OVHCloud + Infisical

**Razón**: OVHCloud no ofrece Secrets Manager, y Infisical es cloud-agnostic.

### Architecture

#### Estructura de Directorios Kustomize

```
k8s/
├── base/                          # Manifests comunes
│   ├── backend/
│   │   ├── deployment.yaml
│   │   ├── service.yaml
│   │   ├── configmap.yaml
│   │   └── kustomization.yaml
│   ├── web-superusers/
│   │   ├── deployment.yaml
│   │   ├── service.yaml
│   │   └── kustomization.yaml
│   └── web-b2g/
│       ├── deployment.yaml
│       ├── service.yaml
│       └── kustomization.yaml
│
└── overlays/                      # Parches por ambiente
    ├── dev/
    │   ├── kustomization.yaml     # namespace: altrupets-dev
    │   ├── backend/
    │   │   ├── kustomization.yaml
    │   │   ├── namespace.yaml
    │   │   └── patch-deployment.yaml
    │   ├── web-superusers/
    │   └── web-b2g/
    ├── qa/
    │   └── kustomization.yaml     # namespace: altrupets-qa
    ├── staging/
    │   └── kustomization.yaml     # namespace: altrupets-staging
    └── prod/
        └── kustomization.yaml     # namespace: altrupets-prod
```

#### Estructura de Directorios Helm

```
infrastructure/helm-charts/
├── gateway-api/                   # Ya existe
│   ├── Chart.yaml
│   ├── values.yaml
│   └── templates/
├── infisical/                     # Por crear
│   ├── Chart.yaml
│   ├── values-dev.yaml
│   ├── values-qa.yaml
│   ├── values-staging.yaml
│   └── values-prod.yaml
└── nginx-gateway/                 # Por crear
    ├── Chart.yaml
    └── values/
        ├── values-dev.yaml
        ├── values-qa.yaml
        ├── values-staging.yaml
        └── values-prod.yaml
```

### Completed

#### Migración de Namespace Hardcodeado a Kustomize Overlays ✅

- [x] `k8s/overlays/dev/kustomization.yaml` - Creado con namespace parameterizado
- [x] `k8s/argocd/applications/backend-dev.yaml` - Actualizado para usar overlay
- [x] `k8s/argocd/applications/web-superusers-dev.yaml` - Actualizado para usar overlay
- [x] `k8s/argocd/applications/web-b2g-dev.yaml` - Actualizado para usar overlay
- [x] `k8s/argocd/projects/altrupets-dev-project.yaml` - Namespace parametrizado

### Configuration Files

#### Modified Files
- `README.md` - Documentación de estrategia Kustomize/Helm
- `README.md` - Actualización de secrets: Infisical (cloud-agnostic)

### References

- [Kustomize Official Docs](https://kubectl.docs.kubernetes.io/guides/introduction/kustomize/)
- [Helm Official Docs](https://helm.sh/docs/)
- [ArgoCD Kustomize Integration](https://argo-cd.readthedocs.io/en/stable/user-guide/kustomize/)
- [Infisical Kubernetes Operator](https://infisical.com/docs/integrations/platforms/kubernetes/overview)
