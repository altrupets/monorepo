# Apollo GraphQL MCP Server - Compilado desde Fuente

## ✅ Estado Actual

Apollo MCP Server ha sido compilado exitosamente desde fuente en tu proyecto. El binario está disponible en:

```
apollo-mcp-server/target/release/apollo-mcp-server
```

## 🚀 Uso Rápido

### Opción 1: Usar el Script Wrapper

```bash
./scripts/apollo-mcp-server.sh --help
```

### Opción 2: Usar el Binario Directamente

```bash
./apollo-mcp-server/target/release/apollo-mcp-server --help
```

## 🔧 Configuración en mcp.json

Para usar Apollo MCP Server en tu configuración de MCP, actualiza `mcp.json`:

```json
{
  "mcpServers": {
    "graphql": {
      "command": "./scripts/apollo-mcp-server.sh",
      "args": [],
      "env": {
        "FASTMCP_LOG_LEVEL": "ERROR"
      }
    }
  }
}
```

O usa la ruta absoluta:

```json
{
  "mcpServers": {
    "graphql": {
      "command": "/home/kvttvrsis/Documentos/GitHub/altrupets-monorepo/apollo-mcp-server/target/release/apollo-mcp-server",
      "args": [],
      "env": {
        "FASTMCP_LOG_LEVEL": "ERROR"
      }
    }
  }
}
```

## 📝 Ejemplos de Uso

### Introspeccionar un Endpoint GraphQL

```bash
./scripts/apollo-mcp-server.sh \
  --endpoint https://api.example.com/graphql \
  --auth-token "Bearer YOUR_TOKEN"
```

### Con Variables de Entorno

```bash
export GRAPHQL_ENDPOINT="https://api.example.com/graphql"
export GRAPHQL_AUTH_TOKEN="Bearer YOUR_TOKEN"

./scripts/apollo-mcp-server.sh
```

### Habilitar Logging Detallado

```bash
FASTMCP_LOG_LEVEL=DEBUG ./scripts/apollo-mcp-server.sh
```

## 🧪 Testing

### Verificar que funciona

```bash
./scripts/apollo-mcp-server.sh --help
```

### Usar con MCP Inspector

```bash
# Terminal 1: Inicia el inspector
npx @modelcontextprotocol/inspector

# Terminal 2: Ejecuta el servidor
./scripts/apollo-mcp-server.sh
```

Luego abre `http://127.0.0.1:6274` en tu navegador.

## 📊 Información del Binario

```bash
# Ver información del binario compilado
file ./apollo-mcp-server/target/release/apollo-mcp-server

# Ver tamaño
ls -lh ./apollo-mcp-server/target/release/apollo-mcp-server

# Ver versión
./scripts/apollo-mcp-server.sh --version
```

## 🔄 Actualizar Apollo MCP Server

Si necesitas actualizar Apollo MCP Server a una versión más reciente:

```bash
# Actualizar el repositorio clonado
cd apollo-mcp-server
git pull origin main

# Recompilar
cd ..
source $HOME/.cargo/env
cargo build --release --manifest-path apollo-mcp-server/Cargo.toml
```

## 🐛 Troubleshooting

### Error: "Permission denied"

```bash
# Asegúrate de que el script es ejecutable
chmod +x scripts/apollo-mcp-server.sh

# O ejecuta el binario directamente
./apollo-mcp-server/target/release/apollo-mcp-server
```

### Error: "Command not found"

```bash
# Verifica que estás en el directorio correcto
pwd

# Usa la ruta absoluta
/home/kvttvrsis/Documentos/GitHub/altrupets-monorepo/scripts/apollo-mcp-server.sh
```

### Error: "GRAPHQL_ENDPOINT not set"

```bash
# Configura el endpoint
export GRAPHQL_ENDPOINT="https://api.example.com/graphql"

# O pasa como argumento
./scripts/apollo-mcp-server.sh --endpoint https://api.example.com/graphql
```

## 📚 Recursos

- [Apollo MCP Server GitHub](https://github.com/apollographql/apollo-mcp-server)
- [Apollo MCP Server Documentation](https://www.apollographql.com/docs/apollo-mcp-server/)
- [Model Context Protocol](https://modelcontextprotocol.io/)

## 🔐 Seguridad

### Proteger Tokens

Nunca commits tokens en el repositorio:

```bash
# Usar variables de entorno
export GRAPHQL_AUTH_TOKEN="your_secret_token"

# O usar .env (agregado a .gitignore)
echo "GRAPHQL_AUTH_TOKEN=your_secret_token" > .env
```

### Validar Certificados SSL

Apollo MCP Server valida certificados SSL por defecto. Para desarrollo local con certificados auto-firmados:

```bash
export INSECURE_SKIP_VERIFY=true
./scripts/apollo-mcp-server.sh
```

## 📋 Notas

- El binario compilado es específico para tu arquitectura (x86_64-unknown-linux-gnu)
- Tamaño del binario: ~43MB (optimizado para release)
- Tiempo de compilación: ~3 minutos
- Requiere Rust 1.93.1 o superior

---

**Última actualización:** Febrero 2026
**Versión:** 1.0.0
