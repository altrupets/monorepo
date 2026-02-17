#!/bin/bash

# ==============================================================================
# AltruPets - Seed Superuser in Minikube
# ==============================================================================
# Creates a SUPER_USER admin account in the Minikube cluster using K8s Secrets
#
# Usage:
#   ./seed-superuser-minikube.sh [username] [password]
#
# Examples:
#   ./seed-superuser-minikube.sh                    # Interactive GUI or CLI
#   ./seed-superuser-minikube.sh myuser mypass123   # Custom credentials (CLI only)
# ==============================================================================

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
NAMESPACE="altrupets-dev"
DEPLOYMENT="backend"

GREEN='\033[0;32m'
BLUE='\033[0;34m'
ORANGE='\033[0;33m'
RED='\033[0;31m'
NC='\033[0m'

SECRET_NAME="backend-seed-secret"
USE_ZENITY=false

# Check if zenity is available
if command -v zenity >/dev/null 2>&1; then
	USE_ZENITY=true
fi

# Function to prompt for credentials using zenity
prompt_zenity() {
	local username
	local password
	local confirm_password

	# Ask for username
	username=$(zenity --entry \
		--title="AltruPets - Crear Superusuario" \
		--text="Ingrese el nombre de usuario para el administrador:" \
		--entry-text="admin" \
		--width=400) || exit 1

	# Ask for password (hidden)
	password=$(zenity --password \
		--title="AltruPets - Contraseña" \
		--text="Ingrese la contraseña:" \
		--width=400) || exit 1

	# Confirm password
	confirm_password=$(zenity --password \
		--title="AltruPets - Confirmar Contraseña" \
		--text="Confirme la contraseña:" \
		--width=400) || exit 1

	# Verify passwords match
	if [ "$password" != "$confirm_password" ]; then
		zenity --error \
			--title="Error" \
			--text="Las contraseñas no coinciden." \
			--width=300
		exit 1
	fi

	# Verify password is not empty and has minimum length
	if [ -z "$password" ] || [ ${#password} -lt 8 ]; then
		zenity --error \
			--title="Error" \
			--text="La contraseña debe tener al menos 8 caracteres." \
			--width=300
		exit 1
	fi

	echo "$username"
	echo "$password"
}

# Function to prompt for credentials using CLI
prompt_cli() {
	local username="${1:-}"
	local password="${2:-}"

	# If not provided as arguments, ask interactively
	if [ -z "$username" ]; then
		echo -n "Usuario (default: admin): "
		read -r username
		username=${username:-admin}
	fi

	if [ -z "$password" ]; then
		while true; do
			echo -n "Contraseña (default: altrupets2026): "
			read -rs password
			echo ""
			password=${password:-altrupets2026}

			if [ ${#password} -ge 8 ]; then
				break
			else
				echo -e "${RED}❌ La contraseña debe tener al menos 8 caracteres${NC}"
			fi
		done
	fi

	echo "$username"
	echo "$password"
}

# Get credentials
echo -e "${BLUE}🌱 AltruPets - Seed Superuser${NC}"
echo ""

if [ "$USE_ZENITY" = true ]; then
	echo -e "${BLUE}🖥️  Usando interfaz gráfica (zenity)...${NC}"
	# Zenity returns both values separated by newline
	readarray -t creds < <(prompt_zenity)
	ADMIN_USERNAME="${creds[0]}"
	ADMIN_PASSWORD="${creds[1]}"
else
	echo -e "${BLUE}💻 Usando línea de comandos...${NC}"
	readarray -t creds < <(prompt_cli "$@")
	ADMIN_USERNAME="${creds[0]}"
	ADMIN_PASSWORD="${creds[1]}"
fi

# Verify we have both values
if [ -z "$ADMIN_USERNAME" ] || [ -z "$ADMIN_PASSWORD" ]; then
	echo -e "${RED}❌ Error: Credenciales no proporcionadas${NC}"
	exit 1
fi

echo ""
echo -e "${BLUE}👤 Usuario: $ADMIN_USERNAME${NC}"

# Verify kubectl is available
if ! command -v kubectl >/dev/null 2>&1; then
	echo -e "${RED}❌ kubectl is not installed${NC}"
	exit 1
fi

# Verify namespace exists
if ! kubectl get ns "$NAMESPACE" >/dev/null 2>&1; then
	echo -e "${RED}❌ Namespace '$NAMESPACE' not found${NC}"
	exit 1
fi

# Verify deployment exists
if ! kubectl get deploy "$DEPLOYMENT" -n "$NAMESPACE" >/dev/null 2>&1; then
	echo -e "${RED}❌ Deployment '$DEPLOYMENT' not found in namespace '$NAMESPACE'${NC}"
	exit 1
fi

echo -e "${BLUE}🔐 Creating/updating Kubernetes Secret...${NC}"

# Create or update the secret
kubectl create secret generic "$SECRET_NAME" \
	--namespace="$NAMESPACE" \
	--from-literal=SEED_ADMIN_USERNAME="$ADMIN_USERNAME" \
	--from-literal=SEED_ADMIN_PASSWORD="$ADMIN_PASSWORD" \
	--dry-run=client -o yaml | kubectl apply -f -

echo -e "${GREEN}✅ Secret '$SECRET_NAME' configured${NC}"

echo -e "${BLUE}⚙️  Configuring deployment to use seed secret...${NC}"

# Patch the deployment to use the secret and enable seeding
kubectl set env deployment/"$DEPLOYMENT" -n "$NAMESPACE" \
	SEED_ADMIN=true

# Add secret references
kubectl patch deployment "$DEPLOYMENT" -n "$NAMESPACE" --type=json -p "[
  {
    \"op\": \"add\",
    \"path\": \"/spec/template/spec/containers/0/envFrom\",
    \"value\": [
      {
        \"secretRef\": {
          \"name\": \"$SECRET_NAME\"
        }
      }
    ]
  }
]" 2>/dev/null || true

echo -e "${BLUE}🔄 Rolling out deployment...${NC}"
kubectl rollout restart deployment/"$DEPLOYMENT" -n "$NAMESPACE"

# Wait for rollout
echo -e "${BLUE}⏳ Waiting for rollout to complete...${NC}"
if kubectl rollout status deployment/"$DEPLOYMENT" -n "$NAMESPACE" --timeout=120s; then
	echo ""
	echo -e "${GREEN}✅ Superuser created successfully!${NC}"
	echo ""
	echo -e "${BLUE}Credentials:${NC}"
	echo "  Username: $ADMIN_USERNAME"
	echo "  Password: [hidden]"
	echo "  Role: SUPER_USER"
	echo ""
	echo -e "${BLUE}Access:${NC}"
	echo "  - Login: http://localhost:3001/login (via port-forward)"
	echo "  - Or through NGINX Gateway Fabric"
	echo ""
	echo -e "${ORANGE}⚠️  Important: Remove the seeding after first use:${NC}"
	echo "  kubectl set env deployment/$DEPLOYMENT -n $NAMESPACE SEED_ADMIN=false"

	# Show success dialog if zenity is available
	if [ "$USE_ZENITY" = true ]; then
		zenity --info \
			--title="Superusuario Creado" \
			--text="El usuario administrador ha sido creado exitosamente.\n\nUsuario: $ADMIN_USERNAME\nRol: SUPER_USER\n\nPuede iniciar sesión en:\nhttp://localhost:3001/login" \
			--width=400
	fi
else
	echo -e "${RED}❌ Rollout failed${NC}"
	echo -e "${ORANGE}Check logs:${NC} kubectl logs -n $NAMESPACE deployment/$DEPLOYMENT --tail=50"

	# Show error dialog if zenity is available
	if [ "$USE_ZENITY" = true ]; then
		zenity --error \
			--title="Error" \
			--text="Falló el despliegue del backend.\n\nVerifique los logs con:\nkubectl logs -n $NAMESPACE deployment/$DEPLOYMENT --tail=50" \
			--width=400
	fi

	exit 1
fi
