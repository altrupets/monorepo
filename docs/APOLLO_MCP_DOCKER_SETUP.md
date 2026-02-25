# Apollo GraphQL MCP Server - Instalación con Docker

## 🐳 Opción Recomendada: Docker

Apollo MCP Server está disponible como imagen Docker, lo que es la forma más fácil de instalarlo sin compilar desde fuente.

## 📋 Requisitos

- Docker instalado y ejecutándose
- `docker` disponible en tu PATH

## 🚀 Instalación Rápida

### 1. Descargar la imagen Docker

```bash
docker pull apollographql/apollo-mcp-server:latest
```

### 2. Ejecutar el servidor

```bash
docker run -it \
  -p 5000:5000 \
  -e GRAPHQL_ENDPOINT="https://api.example.com/graphql" \
  apollographql/apollo-mcp-server:latest
```

### 3. Configurar en mcp.json

```json
{
  "mcpServers": {
    "graphql": {
      "command": "docker",
      "args": [
        "run",
        "--rm",
        "-i",
        "-e", "GRAPHQL_ENDPOINT=https://api.example.com/graphql",
        "apollographql/apollo-mcp-server:latest"
      ],
      "env": {}
    }
  }
}
```

## 🔧 Configuración Avanzada

### Con Autenticación

```bash
docker run -it \
  -p 5000:5000 \
  -e GRAPHQL_ENDPOINT="https://api.example.com/graphql" \
  -e GRAPHQL_AUTH_TOKEN="Bearer YOUR_TOKEN" \
  apollographql/apollo-mcp-server:latest
```

### Con Volumen Montado

```bash
docker run -it \
  -p 5000:5000 \
  -v $(pwd)/apollo-config:/config \
  -e GRAPHQL_ENDPOINT="https://api.example.com/graphql" \
  apollographql/apollo-mcp-server:latest
```

### Con Docker Compose

Crea `docker-compose.yml`:

```yaml
version: '3.8'

services:
  apollo-mcp:
    image: apollographql/apollo-mcp-server:latest
    ports:
      - "5000:5000"
    environment:
      GRAPHQL_ENDPOINT: "https://api.example.com/graphql"
      GRAPHQL_AUTH_TOKEN: "${GRAPHQL_AUTH_TOKEN}"
    volumes:
      - ./apollo-config:/config
```

Luego ejecuta:

```bash
docker-compose up -d
```

## 🧪 Testing

### Verificar que el servidor está corriendo

```bash
# Ver logs
docker logs <container_id>

# Probar conexión
curl http://localhost:5000/health
```

### Usar con MCP Inspector

```bash
# Ejecutar el inspector
npx @modelcontextprotocol/inspector

# Configurar:
# Transport Type: STDIO
# Command: docker
# Arguments: run --rm -i -e GRAPHQL_ENDPOINT=https://api.example.com/graphql apollographql/apollo-mcp-server:latest
```

## 🔐 Variables de Entorno

| Variable | Descripción | Ejemplo |
|----------|-------------|---------|
| `GRAPHQL_ENDPOINT` | URL del endpoint GraphQL | `https://api.example.com/graphql` |
| `GRAPHQL_AUTH_TOKEN` | Token de autenticación | `Bearer eyJhbGc...` |
| `GRAPHQL_HEADERS` | Headers adicionales (JSON) | `{"X-API-Key":"secret"}` |
| `FASTMCP_LOG_LEVEL` | Nivel de logging | `DEBUG`, `INFO`, `WARN`, `ERROR` |

## 🐛 Troubleshooting

### Error: "Cannot connect to Docker daemon"

```bash
# Asegúrate de que Docker está corriendo
sudo systemctl start docker

# O en macOS
open /Applications/Docker.app
```

### Error: "Image not found"

```bash
# Descargar la imagen
docker pull apollographql/apollo-mcp-server:latest

# Verificar imágenes disponibles
docker images | grep apollo
```

### Error: "Port already in use"

```bash
# Usar un puerto diferente
docker run -it -p 5001:5000 apollographql/apollo-mcp-server:latest

# O encontrar qué está usando el puerto
lsof -i :5000
```

## 📚 Recursos

- [Apollo MCP Server Docker Hub](https://hub.docker.com/r/apollographql/apollo-mcp-server)
- [Docker Documentation](https://docs.docker.com/)
- [Docker Compose Documentation](https://docs.docker.com/compose/)

## 🔄 Actualizar la Imagen

```bash
# Descargar la última versión
docker pull apollographql/apollo-mcp-server:latest

# Eliminar versiones antiguas
docker image prune
```

---

**Última actualización:** Febrero 2026
**Versión:** 1.0.0
