# Propuesta: Servidor MCP en Backend NestJS

**Change ID**: `backend-mcp-server`
**Linear**: Nuevo (por crear en Linear)
**Sprint**: Por asignar
**Tamano**: M (dias)
**Journey**: Transversal (infraestructura para agentes AI)

---

## Que

Exponer un servidor MCP (Model Context Protocol) en el backend NestJS de AltruPets, accesible via `POST /mcp`, que permite a agentes AI interactuar directamente con la API de la plataforma.

El servidor MCP expone herramientas (tools) que mapean a operaciones existentes de los resolvers GraphQL:

| Tool MCP | Descripcion | Resolver origen |
|----------|-------------|-----------------|
| `search-animals` | Buscar animales por especie, estado, ubicacion | AnimalsResolver |
| `get-subsidy-status` | Consultar estado de solicitud de subvencion | SubsidiesResolver |
| `list-rescue-requests` | Listar solicitudes de rescate activas | CapturesResolver |
| `get-foster-home-capacity` | Verificar disponibilidad de casas cuna | (por implementar) |
| `create-abuse-report` | Registrar una denuncia de maltrato | AbuseReportsResolver |
| `get-municipal-kpis` | Obtener KPIs del dashboard jurisdiccional | (Government dashboard) |

## Por que

1. **Agentes AI como consumidores de primera clase**: Claude Code, asistentes AI y bots pueden consultar y operar sobre datos de AltruPets sin necesidad de construir clientes GraphQL ad-hoc. Un agente puede buscar animales disponibles, verificar el estado de un subsidio o reportar maltrato animal directamente.

2. **Flujos de trabajo con Claude Code**: Los desarrolladores del equipo usan Claude Code para desarrollo. Con un servidor MCP, Claude Code puede introspeccionar datos reales de la plataforma durante el desarrollo — verificar que los datos de prueba son correctos, consultar el estado de entidades, o probar flujos end-to-end.

3. **Testing automatizado**: Agentes de testing pueden usar las herramientas MCP para ejecutar escenarios de prueba complejos de forma programatica, sin depender de la interfaz grafica.

4. **Features AI futuros**: Base para funcionalidades futuras como:
   - Chatbot de soporte que consulta datos en tiempo real
   - Agente de triaje que asigna prioridades a denuncias automaticamente
   - Asistente para coordinadores municipales que resume KPIs

5. **Estandar abierto**: MCP es un protocolo abierto de Anthropic adoptado por multiples herramientas. Integrarse ahora posiciona a AltruPets para integraciones futuras con cualquier cliente MCP compatible.

## Alcance

### Incluido

- Modulo NestJS `McpModule` con registro de herramientas
- Transporte Streamable HTTP en `POST /mcp` usando `StreamableHTTPServerTransport`
- 6 herramientas MCP con esquemas de parametros definidos via JSON Schema
- Autenticacion JWT en el endpoint MCP (reutiliza el sistema existente)
- Documentacion de herramientas con descripciones en espanol

### Excluido

- Transporte SSE o stdio (solo Streamable HTTP)
- Herramientas de escritura masiva (por seguridad, solo `create-abuse-report` tiene escritura)
- Recursos MCP (resources) y prompts MCP (futuro)
- Interfaz de administracion para gestionar herramientas MCP

## Riesgo

- **Medio**: Es una superficie de API nueva que requiere autenticacion robusta. Mitigado reutilizando el sistema JWT existente.
- **Dependencia externa**: `@modelcontextprotocol/sdk` es relativamente nuevo. Se acopla minimamente (solo transporte y tipos).
