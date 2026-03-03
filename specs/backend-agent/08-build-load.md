# PASO 8: Build y Load en Minikube con Podman

## 8.1 Script de Build

Crear: `infrastructure/scripts/build-agent-image-minikube.sh`

```bash
#!/bin/bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
AGENT_DIR="$PROJECT_ROOT/apps/agent"
BUILD_ID="$(date +%Y%m%d-%H%M%S)"
IMAGE_TAG="localhost/altrupets-agent:${BUILD_ID}"
IMAGE_TAG_DEV="localhost/altrupets-agent:dev"

GREEN='\033[0;32m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${BLUE}Building agent image: ${IMAGE_TAG}${NC}"

for cmd in podman minikube; do
    if ! command -v $cmd >/dev/null 2>&1; then
        echo -e "${RED}$cmd is not installed${NC}"
        exit 1
    fi
done

if ! minikube status >/dev/null 2>&1; then
    echo -e "${RED}minikube is not running${NC}"
    exit 1
fi

if [ ! -d "$AGENT_DIR" ]; then
    echo -e "${RED}Agent directory not found: $AGENT_DIR${NC}"
    exit 1
fi

cd "$PROJECT_ROOT"

if ! podman build -t "${IMAGE_TAG}" -f "$AGENT_DIR/Dockerfile" "$AGENT_DIR" 2>&1; then
    echo -e "${RED}Failed to build agent image${NC}"
    exit 1
fi

podman tag "${IMAGE_TAG}" "${IMAGE_TAG_DEV}"

echo -e "${BLUE}Loading image into minikube...${NC}"
if ! podman save "${IMAGE_TAG_DEV}" | minikube image load -; then
    echo -e "${RED}Failed to load image into minikube${NC}"
    exit 1
fi

echo -e "${GREEN}Image built (${BUILD_ID}) and loaded: ${IMAGE_TAG_DEV}${NC}"
```

Hacerlo ejecutable:

```bash
chmod +x infrastructure/scripts/build-agent-image-minikube.sh
```

## 8.2 Secuencia Completa de Deploy

```bash
# 1. Instalar dependencias del agent
cd apps/agent && pnpm install && cd ../..

# 2. Build imagen
make dev-agent-build

# 3. Deploy FalkorDB + Agent
make dev-agent-deploy

# 4. Verificar pods
kubectl get pods -n altrupets-dev

# 5. Verificar endpoint
make dev-agent-port-forward &
curl http://localhost:4000/health
```
