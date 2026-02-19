# Secrets con Infisical

AltruPets utiliza [Infisical](https://infisical.com) para gestión centralizada de secrets.

## Por qué Infisical

- Cloud-agnostic (funciona en Minikube, OVHCloud, AWS)
- Sincronización automática a Kubernetes
- Integración con Terraform y CLI
- Open source con opción cloud

## Configuración

### 1. Login

```bash
infisical login
```

### 2. Sincronizar secrets

```bash
make dev-infisical-sync-cli
```

O manualmente:

```bash
infisical export --env=dev --projectId <PROJECT_ID> --format=json | \
  jq -r '.[] | "\(.key)=\(.value)"' > secrets.env

kubectl create secret generic backend-secret \
  --from-env-file=secrets.env \
  -n altrupets-dev \
  --dry-run=client -o yaml | kubectl apply -f -
```

## Secrets sincronizados

| Secret | Descripción |
|--------|-------------|
| `DB_HOST` | Host de PostgreSQL |
| `DB_USERNAME` | Usuario de BD |
| `DB_PASSWORD` | Contraseña de BD |
| `DB_NAME` | Nombre de BD |
| `JWT_SECRET` | Secret para JWT |
| `SEED_ADMIN_USERNAME` | Usuario admin inicial |
| `SEED_ADMIN_PASSWORD` | Contraseña admin inicial |

## Estructura en Infisical

```
Project: altrupets-monorepo
├── Environment: dev
│   └── Secrets: DB_*, JWT_SECRET, SEED_ADMIN_*
├── Environment: qa
│   └── Secrets: ...
├── Environment: staging
│   └── Secrets: ...
└── Environment: prod
    └── Secrets: ...
```

## Script de sincronización

```bash
# Usar el script incluido
./infrastructure/scripts/infisical-sync.sh --cli
```

## Troubleshooting

### Secrets no sincronizados

```bash
# Verificar login
infisical user

# Exportar manualmente
infisical export --env=dev --projectId <ID>
```

### Secret desactualizado en Kubernetes

```bash
# Forzar resincronización
make dev-infisical-sync-cli

# Reiniciar pods
kubectl rollout restart deployment/backend -n altrupets-dev
```

## Seguridad

- Tokens con permisos mínimos
- IP whitelist en Cloudflare API tokens
- Secrets rotados cada 90 días
- Auditoría en Infisical dashboard
