# GraphQL MCP Setup - Resumen Completo

## ✅ Lo que se ha completado

### 1. Instalación de Rust y Compilación de Apollo MCP Server

- ✅ Rust 1.93.1 instalado
- ✅ Apollo MCP Server clonado desde GitHub
- ✅ Binario compilado en modo release (~43MB)
- ✅ Ubicación: `apollo-mcp-server/target/release/apollo-mcp-server`

### 2. Creación de Skill de GraphQL

- ✅ Skill completo en `skills/graphql/SKILL.md`
- ✅ Documentación de queries, mutations y subscriptions
- ✅ Ejemplos de código para Flutter
- ✅ Patrones de caché, error handling y testing

### 3. Documentación

- ✅ `docs/APOLLO_MCP_SETUP.md` - Guía de instalación general
- ✅ `docs/APOLLO_MCP_DOCKER_SETUP.md` - Alternativa con Docker
- ✅ `docs/APOLLO_MCP_COMPILED.md` - Guía para binario compilado
- ✅ `scripts/apollo-mcp-server.sh` - Script wrapper para facilitar uso

### 4. Actualización de AGENTS.md

- ✅ Documentación de Apollo GraphQL MCP Server
- ✅ Skill de GraphQL Integration agregado
- ✅ Referencias a documentación actualizada

## 🚀 Cómo Usar Apollo MCP Server

### Opción 1: Script Wrapper (Recomendado)

```bash
./scripts/apollo-mcp-server.sh --help
```

### Opción 2: Binario Directo

```bash
./apollo-mcp-server/target/release/apollo-mcp-server --help
```

### Opción 3: Con Variables de Entorno

```bash
export GRAPHQL_ENDPOINT="https://api.example.com/graphql"
export GRAPHQL_AUTH_TOKEN="Bearer YOUR_TOKEN"

./scripts/apollo-mcp-server.sh
```

## 🔧 Configuración en mcp.json

Para usar Apollo MCP Server en tu IDE, actualiza `mcp.json`:

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

## 📚 Recursos Disponibles

### Documentación

1. **AGENTS.md** - Descripción general de skills y MCP servers
2. **skills/graphql/SKILL.md** - Skill completo de GraphQL para Flutter
3. **docs/APOLLO_MCP_SETUP.md** - Guía de instalación general
4. **docs/APOLLO_MCP_DOCKER_SETUP.md** - Alternativa con Docker
5. **docs/APOLLO_MCP_COMPILED.md** - Guía del binario compilado

### Scripts

- **scripts/apollo-mcp-server.sh** - Wrapper para ejecutar Apollo MCP Server

### Código Fuente

- **apollo-mcp-server/** - Repositorio clonado de Apollo MCP Server
- **apollo-mcp-server/target/release/apollo-mcp-server** - Binario compilado

## 🎯 Próximos Pasos

### 1. Probar Apollo MCP Server

```bash
# Ver ayuda
./scripts/apollo-mcp-server.sh --help

# Usar con MCP Inspector
npx @modelcontextprotocol/inspector
```

### 2. Configurar en tu IDE

- Actualiza `mcp.json` con la configuración de Apollo MCP Server
- Reinicia tu IDE
- Verifica que el servidor está disponible

### 3. Usar en Agentes de IA

Ahora puedes solicitar a tu asistente de IA:

- "Introspecciona el esquema GraphQL de [endpoint]"
- "Genera una query GraphQL para obtener [datos]"
- "Valida esta operación GraphQL"
- "Explora las capacidades de la API GraphQL"

### 4. Implementar GraphQL en tu Proyecto

Usa el skill de GraphQL (`skills/graphql/SKILL.md`) para:

- Integrar GraphQL en tu aplicación Flutter
- Implementar queries, mutations y subscriptions
- Gestionar caché y estado
- Manejar errores y reintentos
- Optimizar rendimiento

## 📊 Información del Sistema

### Rust

```bash
rustc --version
# rustc 1.93.1 (01f6ddf75 2026-02-11)

cargo --version
# cargo 1.93.1 (083ac5135 2025-12-15)
```

### Apollo MCP Server

```bash
# Verificar binario
ls -lh apollo-mcp-server/target/release/apollo-mcp-server
# -rwxrwxr-x 2 kvttvrsis kvttvrsis 43M feb 16 23:44

# Ver versión
./scripts/apollo-mcp-server.sh --version
```

## 🔐 Seguridad

### Proteger Tokens

```bash
# Usar variables de entorno
export GRAPHQL_AUTH_TOKEN="your_secret_token"

# O usar .env (agregado a .gitignore)
echo "GRAPHQL_AUTH_TOKEN=your_secret_token" > .env
```

### Validar Certificados SSL

Apollo MCP Server valida certificados SSL por defecto. Para desarrollo local:

```bash
export INSECURE_SKIP_VERIFY=true
./scripts/apollo-mcp-server.sh
```

## 🐛 Troubleshooting

### Error: "Command not found"

```bash
# Asegúrate de estar en el directorio correcto
pwd

# Usa la ruta absoluta
/home/kvttvrsis/Documentos/GitHub/altrupets-monorepo/scripts/apollo-mcp-server.sh
```

### Error: "Permission denied"

```bash
# Haz el script ejecutable
chmod +x scripts/apollo-mcp-server.sh
```

### Error: "GRAPHQL_ENDPOINT not set"

```bash
# Configura el endpoint
export GRAPHQL_ENDPOINT="https://api.example.com/graphql"
```

## 📝 Notas Importantes

1. **Binario compilado** - Específico para tu arquitectura (x86_64-unknown-linux-gnu)
2. **Tamaño** - ~43MB (optimizado para release)
3. **Tiempo de compilación** - ~3 minutos
4. **Requisitos** - Rust 1.93.1 o superior

## 🔄 Actualizar Apollo MCP Server

Si necesitas una versión más reciente:

```bash
# Actualizar el repositorio
cd apollo-mcp-server
git pull origin main

# Recompilar
cd ..
source $HOME/.cargo/env
cargo build --release --manifest-path apollo-mcp-server/Cargo.toml
```

## 📞 Soporte

Para más información:

- [Apollo MCP Server GitHub](https://github.com/apollographql/apollo-mcp-server)
- [Apollo GraphQL Documentation](https://www.apollographql.com/docs/)
- [Model Context Protocol](https://modelcontextprotocol.io/)

---

**Última actualización:** Febrero 2026
**Versión:** 1.0.0
**Estado:** ✅ Completado
