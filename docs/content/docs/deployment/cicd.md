# 🚀 CI/CD

## GitHub Actions

El proyecto utiliza **GitHub Actions** para CI/CD con despliegue en **OVHCloud**.

### Pipelines

| Pipeline | Trigger | Entorno |
|----------|---------|---------|
| `ci-build-push.yml` | Push a main | Build imágenes |
| `deploy-qa.yml` | Push a main | QA (OVHCloud) |
| `deploy-staging.yml` | Manual | STAGING (OVHCloud) |
| `deploy-prod.yml` | PR a production | PROD (OVHCloud) |

### Flujo de Deploy

```
main → QA (auto) → STAGING (manual) → PROD (PR + approvals)
```

### Secrets Requeridos

```yaml
OVH_QA_KUBECONFIG       # Kubeconfig para QA
OVH_STAGING_KUBECONFIG  # Kubeconfig para Staging
OVH_PROD_KUBECONFIG     # Kubeconfig para Production
QA_POSTGRES_PASSWORD
STAGING_POSTGRES_PASSWORD
```

### Ambientes GitHub

- **qa**: Auto-deploy desde main
- **staging**: Deploy manual
- **production**: Requiere 2 approvals
