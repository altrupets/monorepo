#!/bin/bash

# Apollo MCP Server Wrapper Script
# Este script facilita la ejecución de Apollo MCP Server compilado desde fuente

set -e

# Directorio del script
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
APOLLO_MCP_BIN="$PROJECT_ROOT/apollo-mcp-server/target/release/apollo-mcp-server"

# Verificar que el binario existe
if [ ! -f "$APOLLO_MCP_BIN" ]; then
    echo "❌ Error: Apollo MCP Server binary not found at $APOLLO_MCP_BIN"
    echo "Please compile it first with:"
    echo "  cargo build --release --manifest-path apollo-mcp-server/Cargo.toml"
    exit 1
fi

# Ejecutar Apollo MCP Server
exec "$APOLLO_MCP_BIN" "$@"
