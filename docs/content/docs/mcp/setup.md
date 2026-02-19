# MCP Setup Guide

Guía detallada de configuración de MCP servers.

## Instalación

Los MCP servers se ejecutan via `npx` (Node.js) o binarios locales. No requieren instalación permanente.

## Configuración Individual

### Context7 (Documentación)

```bash
# Configurar API key
export CONTEXT7_API_KEY="ctx7sk-xxx"

# O en mcp.json
{
  "mcpServers": {
    "context7": {
      "command": "npx",
      "args": ["-y", "@upstash/context7-mcp"],
      "env": {
        "CONTEXT7_API_KEY": "ctx7sk-xxx"
      }
    }
  }
}
```

Obtener API key: https://context7.com

### Dart/Flutter MCP

```bash
# Requiere Dart SDK
dart mcp-server --force-roots-fallback
```

### Apollo GraphQL MCP

```bash
npx -y @apollographql/apollo-mcp-server
```

Nota: Requiere configuración de endpoint GraphQL.

### Mobile MCP

```bash
npx -y @mobilenext/mobile-mcp@latest
```

Gestión de dispositivos Android/iOS para testing.

### Stitch MCP (UI Generation)

```bash
# Autenticación Google Cloud requerida
gcloud auth application-default login

# Ejecutar
GOOGLE_CLOUD_PROJECT="your-project" npx -y stitch-mcp
```

## Integración con IDE

### Claude Code

Claude Code lee automáticamente `mcp.json` desde la raíz del proyecto.

### Cursor

Configurar en `.cursor/mcp.json` con el mismo formato.

### VS Code (Copilot)

Instalar extensión MCP y apuntar a `mcp.json`.

## Logs y Debugging

```bash
# Ver logs de MCP servers
tail -f /tmp/mcp-servers/*.log

# Verificar procesos activos
ps aux | grep mcp
```

## Seguridad

- Las API keys se almacenan en `mcp.json` (agregar a `.gitignore` para proyectos privados)
- Usar variables de entorno para credenciales sensibles
- Los PIDs se almacenan en `/tmp/mcp-servers/`
