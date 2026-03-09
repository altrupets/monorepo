#!/bin/bash

# Apollo MCP Server Wrapper Script
# Este script facilita la ejecución de Apollo MCP Server compilado desde fuente

set -e

# Directorio del script
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
# Ejecutar Apollo MCP Server vía npx
exec npx -y @apollographql/apollo-mcp-server "$@"
