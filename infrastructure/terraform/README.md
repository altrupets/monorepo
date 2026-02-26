# Infrastructure as Code - Terraform/OpenTofu

Este directorio contiene la configuración de infraestructura usando Terraform o OpenTofu para desplegar PostgreSQL en Minikube para desarrollo local.

## Requisitos

- **Terraform** (>= 1.0) **o** **OpenTofu** (>= 1.0)
- **Minikube** corriendo
- **kubectl** configurado y apuntando a Minikube

## Instalación

### Opción 1: Terraform (Hashicorp)

```bash
# Ubuntu/Debian
wget -O- https://apt.releases.hashicorp.com/gpg | sudo gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg
echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list
sudo apt update && sudo apt install terraform

# Verificar instalación
terraform version
```

### Opción 2: OpenTofu (Fork open-source de Terraform)

```bash
# Ubuntu/Debian - Descargar último release
wget https://github.com/opentofu/opentofu/releases/latest/download/tofu_1.6.0-1_amd64.deb
sudo dpkg -i tofu_1.6.0-1_amd64.deb

# Verificar instalación
tofu version
```

**Nota:** Los archivos `.tf` son compatibles con ambos. El script `deploy-postgres-dev.sh` detecta automáticamente cuál está instalado.

## Uso Rápido

### Usando el script automatizado (recomendado)

```bash
# El script hace todo automáticamente:
# - Detecta Terraform/OpenTofu
# - Inicia Minikube si no está corriendo
# - Pide/postea el password de PostgreSQL y lo guarda en environments/dev/.env
# - Despliega PostgreSQL
./infrastructure/scripts/deploy-postgres-dev.sh
```

**Nota:** El script iniciará Minikube automáticamente si no está corriendo. En el primer inicio puede tardar varios minutos.

### Uso manual

```bash
# 1. Ir al directorio de configuración
cd infrastructure/terraform/environments/dev

# 2. Crear archivo de variables desde el ejemplo (opcional)
cp terraform.tfvars.example terraform.tfvars

# 3. Editar terraform.tfvars con tus credenciales
nano terraform.tfvars

# 4. Inicializar (funciona con terraform o tofu)
terraform init
# o
tofu init

# 5. Aplicar configuración
terraform apply
# o
tofu apply
```

## Estructura

```
infrastructure/terraform/
├── modules/
│   ├── database/
│   │   └── postgres-minikube/    # Self-managed PostgreSQL (dev, qa, staging)
│   └── kubernetes/
│       ├── cert-manager/         # TLS certificates
│       └── gateway-api/          # Gateway API + NGINX
└── environments/
    ├── dev/                      # Minikube (desarrollo local)
                          # OVH ├── qa/Cloud Kubernetes + self-managed PostgreSQL
    ├── staging/                  # OVHCloud Kubernetes + self-managed PostgreSQL
    └── prod/                     # OVHCloud Kubernetes + OVH Managed PostgreSQL
        ├── main.tf
        ├── variables.tf
        ├── versions.tf
        ├── terraform.tfvars.example
        └── .gitignore
```

## Ambientes

| Ambiente | K8s | PostgreSQL | Propósito |
|----------|-----|------------|-----------|
| **dev** | Minikube (local) | Self-managed | Desarrollo local |
| **qa** | OVHCloud | Self-managed | Testing efímero |
| **staging** | OVHCloud | Self-managed | Pre-producción |
| **prod** | OVHCloud | OVH Managed | Producción |

## Despliegue a OVHCloud (QA/Staging/Prod)

### Estructura de Infisical

| Proyecto Infisical | Ambientes | Uso |
|-------------------|-----------|-----|
| **altrupets** | dev, qa, stage | Desarrollo, QA, Staging |
| **altrupets-prod** | prod | Producción |

**Nota:** El plan gratuito de Infisical solo permite 3 ambientes por proyecto.

### Secrets requeridos en Infisical

Para cada proyecto, crear los siguientes secrets:

```
/ovh/service_name
/ovh/application_key
/ovh/application_secret
/ovh/consumer_key
/cloudflare/api_token
```

### Despliegue (usando script automatizado)

El script `deploy-terraform.sh` maneja automáticamente:
- Carga de secrets desde Infisical
- Inicializacion de Terraform
- Plan/Apply/Destroy

#### QA

```bash
./infrastructure/scripts/deploy-terraform.sh qa
# Mostrar plan sin aplicar
./infrastructure/scripts/deploy-terraform.sh qa --plan
```

#### Staging

```bash
./infrastructure/scripts/deploy-terraform.sh staging
./infrastructure/scripts/deploy-terraform.sh staging --plan
```

#### Prod

```bash
./infrastructure/scripts/deploy-terraform.sh prod --plan  # Siempre revisar plan primero
./infrastructure/scripts/deploy-terraform.sh prod          # Requiere aprobacion manual
```

### Guardar kubeconfig

```bash
# El kubeconfig se genera automáticamente en kubeconfig
export KUBECONFIG=$(pwd)/kubeconfig

# Verificar conexión
kubectl get nodes
```

## Variables Requeridas

Puedes definir variables en `environments/dev/terraform.tfvars` o pasar `TF_VAR_*`:

```hcl
postgres_username = "postgres"
postgres_password = "tu-password-seguro-aqui"
postgres_database = "altrupets_dev_database"
```

Para entorno local se recomienda guardar el secret en:

`infrastructure/terraform/environments/dev/.env`

Ejemplo:

```bash
DB_PASSWORD=tu-password-seguro-aqui
POSTGRES_USERNAME=postgres
POSTGRES_DATABASE=altrupets_dev_database
```

## Outputs

Después del despliegue, puedes obtener información de conexión:

```bash
terraform output
# o
tofu output
```

## Destruir Recursos

```bash
terraform destroy
# o
tofu destroy
```

## Compatibilidad Terraform vs OpenTofu

- ✅ Los archivos `.tf` son 100% compatibles entre ambos
- ✅ El script `deploy-postgres-dev.sh` detecta automáticamente cuál usar
- ✅ Puedes usar comandos `terraform` o `tofu` indistintamente
- ⚠️ El estado (`.tfstate`) es compatible, pero se recomienda usar el mismo tool consistentemente

## Troubleshooting

**Error: "command not found: terraform"**
- Instala Terraform o OpenTofu siguiendo las instrucciones arriba

**Error: "Minikube is not running"**
```bash
minikube start
```

**Error: "kubectl context not set"**
```bash
kubectl config use-context minikube
```

**Error: "Provider kubernetes not found"**
```bash
terraform init  # o tofu init
```
