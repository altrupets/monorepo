# ☸️ Kubernetes

## Arquitectura de Despliegue

AltruPets se despliega en **OVHCloud Managed Kubernetes** para QA, STAGING y PROD.

```
┌─────────────────────────────────────────────────┐
│              OVHCloud Kubernetes Cluster         │
├─────────────────────────────────────────────────┤
│  ┌─────────────┐  ┌─────────────┐              │
│  │   Ingress   │  │   Ingress   │              │
│  │ Controller  │  │   (SSL)     │              │
│  └──────┬──────┘  └──────┬──────┘              │
│         │                │                      │
│  ┌──────▼──────┐  ┌──────▼──────┐              │
│  │   Backend   │  │   Backend   │  (Replicas)  │
│  │   NestJS    │  │   NestJS    │              │
│  └──────┬──────┘  └──────┬──────┘              │
│         │                │                      │
│  ┌──────▼──────┐  ┌──────▼──────┐              │
│  │ PostgreSQL  │  │   Valkey    │              │
│  │  (Managed)  │  │   (Cache)   │              │
│  └─────────────┘  └─────────────┘              │
└─────────────────────────────────────────────────┘
```

## Entornos

| Entorno | Propósito | Kubeconfig Secret |
|---------|-----------|-------------------|
| **QA** | Ephemeral testing | `OVH_QA_KUBECONFIG` |
| **STAGING** | Pre-production | `OVH_STAGING_KUBECONFIG` |
| **PROD** | Production | `OVH_PROD_KUBECONFIG` |

## Comandos Útiles

```bash
# Ver pods
kubectl get pods -n altrupets

# Ver servicios
kubectl get services -n altrupets

# Logs
kubectl logs -f deployment/backend -n altrupets

# Escalar
kubectl scale deployment/backend --replicas=3 -n altrupets
```

## OVH Managed PostgreSQL

Producción utiliza **OVH Managed PostgreSQL** en lugar de PostgreSQL self-managed:
- Alta disponibilidad
- Backups automáticos
- SSL habilitado
