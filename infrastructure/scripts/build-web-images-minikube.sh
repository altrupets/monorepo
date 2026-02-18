#!/bin/bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
APP_NAME="${1:-all}"

GREEN='\033[0;32m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m'

build_app() {
	local app="$1"
	local app_dir="$PROJECT_ROOT/apps/web/$app"
	local image_tag="altrupets-web-$app:dev"

	echo -e "${BLUE}🐳 Building $app image for Minikube: ${image_tag}${NC}"

	if [ ! -d "$app_dir" ]; then
		echo -e "${RED}❌ App directory not found: $app_dir${NC}"
		exit 1
	fi

	cd "$app_dir"

	if ! minikube image build -t "${image_tag}" -f Dockerfile . 2>&1; then
		echo -e "${RED}❌ Failed to build $app image${NC}"
		exit 1
	fi

	echo -e "${GREEN}✅ Image built: ${image_tag}${NC}"
}

if ! command -v minikube >/dev/null 2>&1; then
	echo -e "${RED}❌ minikube is not installed${NC}"
	exit 1
fi

if ! minikube status >/dev/null 2>&1; then
	echo -e "${RED}❌ minikube is not running. Start it first.${NC}"
	exit 1
fi

case "$APP_NAME" in
superusers)
	build_app "crud-superusers"
	;;
b2g)
	build_app "b2g"
	;;
all)
	build_app "crud-superusers"
	build_app "b2g"
	;;
*)
	echo -e "${RED}❌ Unknown app: $APP_NAME${NC}"
	echo "Usage: $0 [superusers|b2g|all]"
	exit 1
	;;
esac

echo -e "${GREEN}✅ All web images built successfully${NC}"
