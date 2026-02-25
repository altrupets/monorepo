# Apollo GraphQL MCP Server Setup

## 📋 Descripción

Apollo MCP Server es un servidor Model Context Protocol que permite a agentes de IA interactuar con APIs GraphQL. Proporciona herramientas para:

- Introspección de esquemas GraphQL
- Generación de queries y mutations
- Validación de operaciones GraphQL
- Exploración de APIs GraphQL

## ⚠️ Requisitos Previos

Apollo MCP Server está escrito en Rust y requiere:

1. **Rust instalado** - [Instalar Rust](https://www.rust-lang.org/tools/install)
2. **uv instalado** - Python package manager moderno
3. **Node.js 18+** (opcional, para desarrollo)

## 🚀 Instalación de `uv`

### En Linux/macOS

```bash
# Opción 1: Usando curl (recomendado)
curl -LsSf https://astral.sh/uv/install.sh | sh

# Opción 2: Usando Homebrew (macOS)
brew install uv

# Opción 3: Usando pip
pip install uv
```

### En Windows

```powershell
# Usando PowerShell
powershell -ExecutionPolicy ByPass -c "irm https://astral.sh/uv/install.ps1 | iex"

# O usando Scoop
scoop install uv
```

### Verificar instalación

```bash
uv --version
```

## 🔧 Configuración en mcp.json

Una vez instalado `uv`, actualiza tu `mcp.json`:

```json
{
  "mcpServers": {
    "graphql": {
      "command": "uvx",
      "args": [
        "apollo-mcp-server@latest"
      ],
      "env": {
        "FASTMCP_LOG_LEVEL": "ERROR"
      }
    }
  }
}
```

## 📝 Configuración de Endpoints GraphQL

Apollo MCP Server puede trabajar con cualquier endpoint GraphQL. Para configurar endpoints específicos, crea un archivo de configuración:

### Opción 1: Variables de Entorno

```bash
export GRAPHQL_ENDPOINT="https://api.example.com/graphql"
export GRAPHQL_AUTH_TOKEN="Bearer YOUR_TOKEN"
```

### Opción 2: Archivo de Configuración

Crea `apollo-mcp.config.json`:

```json
{
  "endpoints": [
    {
      "name": "Production API",
      "url": "https://api.example.com/graphql",
      "headers": {
        "Authorization": "Bearer YOUR_TOKEN"
      }
    },
    {
      "name": "Development API",
      "url": "http://localhost:4000/graphql"
    }
  ]
}
```

## 🧪 Testing

### Verificar que el servidor funciona

```bash
# Ejecutar el servidor directamente
uvx apollo-mcp-server@latest --help
```

### Usar con MCP Inspector

```bash
# En una terminal, inicia el inspector
npx @modelcontextprotocol/inspector

# En otra terminal, ejecuta el servidor
uvx apollo-mcp-server@latest
```

Luego abre `http://127.0.0.1:6274` en tu navegador.

## 🔗 Integración con Agentes de IA

### Con Cursor/Cline

1. Abre la configuración de MCP en Cursor
2. Verifica que `mcp.json` está correctamente configurado
3. Reinicia Cursor
4. Usa comandos como:
   - "Introspecciona el esquema GraphQL de [endpoint]"
   - "Genera una query GraphQL para obtener [datos]"
   - "Valida esta operación GraphQL"

### Con Claude/ChatGPT

Si usas Claude o ChatGPT con MCP:

```bash
# Ejecutar servidor en background
uvx apollo-mcp-server@latest &

# Conectar tu cliente de IA al servidor
```

## 🐛 Troubleshooting

### Error: "apollo-mcp-server not found"

```bash
# Asegúrate de que uv está instalado
uv --version

# Intenta instalar explícitamente
uv pip install apollo-mcp-server
```

### Error: "GRAPHQL_ENDPOINT not set"

```bash
# Configura el endpoint
export GRAPHQL_ENDPOINT="https://api.example.com/graphql"

# O usa el archivo de configuración
export APOLLO_MCP_CONFIG="./apollo-mcp.config.json"
```

### Error: "Connection refused"

- Verifica que el endpoint GraphQL está disponible
- Comprueba la URL y el puerto
- Verifica tokens de autenticación

### Error: "Rust not found"

```bash
# Instala Rust
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh

# Recarga el shell
source $HOME/.cargo/env
```

## 📚 Recursos

- [Apollo MCP Server GitHub](https://github.com/apollographql/apollo-mcp-server)
- [Apollo MCP Server Blog](https://www.apollographql.com/blog/getting-started-with-apollo-mcp-server-for-any-graphql-api)
- [Model Context Protocol Docs](https://modelcontextprotocol.io/)
- [uv Documentation](https://docs.astral.sh/uv/)

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

```json
{
  "mcpServers": {
    "graphql": {
      "command": "uvx",
      "args": [
        "apollo-mcp-server@latest",
        "--verify-ssl=true"
      ],
      "env": {}
    }
  }
}
```

## 📊 Monitoreo

### Habilitar Logging

```json
{
  "mcpServers": {
    "graphql": {
      "command": "uvx",
      "args": [
        "apollo-mcp-server@latest"
      ],
      "env": {
        "FASTMCP_LOG_LEVEL": "DEBUG"
      }
    }
  }
}
```

Niveles disponibles: `ERROR`, `WARN`, `INFO`, `DEBUG`, `TRACE`

---

**Última actualización:** Febrero 2026
**Versión:** 1.0.0
