# TLS/HTTPS

AltruPets utiliza Let's Encrypt para certificados TLS automáticos.

## Arquitectura

```
┌─────────────────┐
│   Cloudflare    │ DNS Provider
│   (DNS-01)      │
└────────┬────────┘
         │
         ▼
┌─────────────────┐
│  cert-manager   │ Gestión de certificados
│  (Kubernetes)   │
└────────┬────────┘
         │
         ▼
┌─────────────────┐
│ NGINX Gateway   │ TLS Termination
│    Fabric       │
└─────────────────┘
```

## Componentes

### cert-manager

```bash
# Instalación
helm install cert-manager jetstack/cert-manager \
  --namespace cert-manager \
  --create-namespace \
  --set crds.enabled=true
```

### ClusterIssuers

| Issuer | Uso |
|--------|-----|
| `letsencrypt-staging` | Desarrollo, pruebas |
| `letsencrypt-prod` | Producción |

### Certificate

```yaml
apiVersion: cert-manager.io/v1
kind: Certificate
metadata:
  name: altrupets-app-tls
spec:
  secretName: altrupets-app-tls
  issuerRef:
    name: letsencrypt-staging  # o letsencrypt-prod
    kind: ClusterIssuer
  dnsNames:
    - altrupets.app
    - "*.altrupets.app"
```

## Configuración

### Variables requeridas

| Variable | Descripción |
|----------|-------------|
| `CLOUDFLARE_API_TOKEN` | Token con permisos DNS edit |
| `CLOUDFLARE_ZONE_ID` | ID de la zona en Cloudflare |

### Terraform

```hcl
module "cert_manager" {
  source = "../../modules/kubernetes/cert-manager"
  
  environment           = "dev"
  namespace             = "altrupets-dev"
  domain_name           = "altrupets.app"
  acme_email            = "altrupets.workspace@gmail.com"
  cloudflare_api_token  = var.cloudflare_api_token
}
```

## Validación DNS-01

1. cert-manager crea registro TXT en `_acme-challenge.altrupets.app`
2. Let's Encrypt valida el registro
3. cert-manager emite el certificado
4. Secret creado en `altrupets-app-tls`

## Ambientes

| Ambiente | Issuer | Dominio |
|----------|--------|---------|
| DEV | staging | localhost (sin TLS) |
| QA | staging | qa.altrupets.app |
| STAGING | prod | staging.altrupets.app |
| PROD | prod | altrupets.app |

## Troubleshooting

### Certificate pending

```bash
kubectl describe certificate altrupets-app-tls -n altrupets-dev
kubectl get challenge -n altrupets-dev
```

### DNS propagation

```bash
dig TXT _acme-challenge.altrupets.app @1.1.1.1
```

### Logs

```bash
kubectl logs -n cert-manager deployment/cert-manager
```

## Renovación

Los certificados se renuevan automáticamente 30 días antes de expirar.

## Rate Limits

Let's Encrypt tiene límites:
- Staging: sin límite estricto
- Production: 50 certificados/semana por dominio

Usar staging para desarrollo.
