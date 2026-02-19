# MCP Servers

Model Context Protocol (MCP) servers proporcionan capacidades especializadas para el desarrollo.

## Servidores Disponibles

| Servidor | Propósito | Comando |
|----------|-----------|---------|
| **context7** | Documentación técnica | `npx -y @upstash/context7-mcp` |
| **dart** | Flutter/Dart análisis | `dart mcp-server` |
| **graphql** | GraphQL introspection | `npx -y @apollographql/apollo-mcp-server` |
| **mobile-mcp** | Gestión de dispositivos | `npx -y @mobilenext/mobile-mcp` |
| **stitch** | Generación de UI | `npx -y stitch-mcp` |

## Configuración

Ver [mcp.json](../../../mcp.json) en la raíz del proyecto.

## Comandos Makefile

```bash
make dev-mcp-start    # Iniciar todos los MCP servers
make dev-mcp-stop     # Detener todos los MCP servers
make dev-mcp-status   # Ver estado de los servers
```

## Requisitos

- **context7**: API key en `CONTEXT7_API_KEY`
- **stitch**: `gcloud auth application-default login`
- **dart**: Dart SDK instalado

## Troubleshooting

### stitch-mcp: Authentication failed
```bash
gcloud auth application-default login
```

### context7: API key expired
Regenerar API key en [Upstash Context7](https://context7.com)
