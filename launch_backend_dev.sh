#!/bin/bash

# ==============================================================================
# AltruPets - Backend Development Server Launch Script
# ==============================================================================
# Usage: ./launch_backend_dev.sh [options]
#
# Options:
#   --superuser     Create initial admin user with SUPER_USER role
#   --no-build      Skip build step (just run)
#   --watch         Run in watch mode (auto-reload on changes)
#   --debug         Enable debug mode with inspector
#
# Examples:
#   ./launch_backend_dev.sh                    # Start dev server
#   ./launch_backend_dev.sh --superuser        # Start with admin SUPER_USER
#   ./launch_backend_dev.sh --watch            # Start in watch mode
# ==============================================================================

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BACKEND_DIR="$SCRIPT_DIR/apps/backend"

colors() {
	GREEN='\033[0;32m'
	BLUE='\033[0;34m'
	ORANGE='\033[0;33m'
	RED='\033[0;31m'
	NC='\033[0m'
}

colors

# Parse arguments
SUPERUSER_ENABLED=false
NO_BUILD=false
WATCH_MODE=false
DEBUG_MODE=false

while [[ $# -gt 0 ]]; do
	case "$1" in
	--superuser)
		SUPERUSER_ENABLED=true
		shift
		;;
	--no-build)
		NO_BUILD=true
		shift
		;;
	--watch)
		WATCH_MODE=true
		shift
		;;
	--debug)
		DEBUG_MODE=true
		shift
		;;
	-h | --help)
		echo -e "${BLUE}AltruPets Backend Development Server${NC}"
		echo ""
		echo "Usage: ./launch_backend_dev.sh [options]"
		echo ""
		echo "Options:"
		echo "  --superuser     Create initial admin user with SUPER_USER role"
		echo "  --no-build      Skip build step (just run)"
		echo "  --watch         Run in watch mode (auto-reload on changes)"
		echo "  --debug         Enable debug mode with inspector"
		echo "  -h, --help      Show this help"
		echo ""
		echo "Examples:"
		echo "  ./launch_backend_dev.sh"
		echo "  ./launch_backend_dev.sh --superuser"
		echo "  ./launch_backend_dev.sh --watch --superuser"
		exit 0
		;;
	*)
		echo -e "${RED}❌ Unknown option: $1${NC}"
		echo "Run with --help for usage information"
		exit 1
		;;
	esac
done

echo -e "${BLUE}╔════════════════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║       AltruPets Backend - Development Server               ║${NC}"
echo -e "${BLUE}╚════════════════════════════════════════════════════════════╝${NC}"
echo ""

# Verify we're in the right directory
if [ ! -f "$BACKEND_DIR/package.json" ]; then
	echo -e "${RED}❌ Error: Backend directory not found at $BACKEND_DIR${NC}"
	echo "Please run this script from the project root"
	exit 1
fi

# Check Node.js version
if ! command -v node &>/dev/null; then
	echo -e "${RED}❌ Node.js is not installed${NC}"
	exit 1
fi

echo -e "${BLUE}📁 Backend directory: $BACKEND_DIR${NC}"
cd "$BACKEND_DIR"

# Setup environment for local development
if [ -f ".env.local" ]; then
	echo -e "${BLUE}📄 Using .env.local for local development${NC}"
	export $(grep -v '^#' .env.local | xargs)
fi

# Check if dependencies are installed
if [ ! -d "node_modules" ]; then
	echo -e "${ORANGE}⚠️  node_modules not found. Installing dependencies...${NC}"
	npm install
fi

# Build step (unless --no-build)
if [ "$NO_BUILD" = false ]; then
	echo -e "${BLUE}🔨 Building TypeScript...${NC}"
	npm run build
	if [ $? -eq 0 ]; then
		echo -e "${GREEN}✅ Build successful${NC}"
	else
		echo -e "${RED}❌ Build failed${NC}"
		exit 1
	fi
else
	echo -e "${ORANGE}⏩ Skipping build (--no-build)${NC}"
fi

# Set environment variables for dev mode
export NODE_ENV=development
export ENV_NAME=dev

# Enable superuser creation if requested
if [ "$SUPERUSER_ENABLED" = true ]; then
	echo -e "${BLUE}🌱 Superuser creation enabled${NC}"
	export SEED_ADMIN=true
	export SEED_ADMIN_USERNAME=admin
	export SEED_ADMIN_PASSWORD=${SEED_ADMIN_PASSWORD:-altrupets2026}
fi

# Prepare the run command
RUN_CMD=""
if [ "$WATCH_MODE" = true ]; then
	echo -e "${BLUE}👀 Watch mode enabled (auto-reload)${NC}"
	RUN_CMD="npm run start:dev"
elif [ "$DEBUG_MODE" = true ]; then
	echo -e "${BLUE}🐛 Debug mode enabled${NC}"
	RUN_CMD="npm run start:debug"
else
	RUN_CMD="npm run start:dev"
fi

echo ""
echo -e "${BLUE}🚀 Starting development server...${NC}"
echo -e "${BLUE}   GraphQL: http://localhost:3001/graphql${NC}"
echo -e "${BLUE}   Web:     http://localhost:3001${NC}"
echo ""
echo -e "${ORANGE}Press Ctrl+C to stop${NC}"
echo ""

# Run the server
exec $RUN_CMD
