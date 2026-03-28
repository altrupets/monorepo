# Tareas: Servidor MCP en Backend NestJS

**Change ID**: `backend-mcp-server`
**Sprint**: Por asignar | **Tamano**: M (dias)

---

## Fase 1: Instalacion y Modulo Base

- [ ] Instalar dependencias: `@modelcontextprotocol/sdk`, `zod`
- [ ] Crear `src/mcp/mcp.module.ts` con imports de los modulos de dominio necesarios (Animals, Subsidies, Captures, AbuseReports, Users, Auth)
- [ ] Crear `src/mcp/mcp.service.ts` con inicializacion de `McpServer` en `onModuleInit()`
- [ ] Crear `src/mcp/mcp.controller.ts` con endpoint `POST /mcp` usando `StreamableHTTPServerTransport`
- [ ] Importar `McpModule` en `AppModule`
- [ ] Verificar que el servidor arranca sin errores con el modulo vacio (sin herramientas)

## Fase 2: Autenticacion del Endpoint

- [ ] Implementar validacion JWT en `McpController.handleMcp()` usando `AuthService.validateToken()`
- [ ] Extraer usuario del token y hacerlo disponible como contexto para los handlers de herramientas
- [ ] Verificar que requests sin token o con token invalido retornan 401
- [ ] Verificar que requests con token valido procesan correctamente el handshake MCP (`initialize`)

## Fase 3: Registro de Herramientas

- [ ] Implementar `search-animals` — busqueda de animales por especie, estado, ubicacion (AnimalsService)
- [ ] Implementar `get-subsidy-status` — consulta de estado de subvencion por ID (SubsidiesService)
- [ ] Implementar `list-rescue-requests` — listado de solicitudes de rescate activas (CapturesService)
- [ ] Implementar `get-foster-home-capacity` — disponibilidad de casas cuna por zona (UsersService/query)
- [ ] Implementar `create-abuse-report` — registro de denuncia de maltrato (AbuseReportsService)
- [ ] Implementar `get-municipal-kpis` — KPIs jurisdiccionales agregados (Government queries)
- [ ] Definir schemas Zod con descripciones en espanol para cada herramienta
- [ ] Verificar que `tools/list` retorna las 6 herramientas con sus schemas

## Fase 4: RBAC por Herramienta

- [ ] Implementar verificacion de roles en cada handler de herramienta segun tabla de permisos del diseno
- [ ] `get-municipal-kpis`: restringir a `GOVERNMENT_ADMIN`
- [ ] `get-subsidy-status`: restringir a `RESCUER`, `VET`, `GOVERNMENT_ADMIN`
- [ ] `list-rescue-requests`: restringir a `RESCUER`, `AUXILIARY`, `GOVERNMENT_ADMIN`
- [ ] Retornar error MCP descriptivo cuando el usuario no tiene el rol requerido

## Fase 5: Testing

- [ ] Test unitario: `McpService` inicializa correctamente y registra las 6 herramientas
- [ ] Test unitario: cada handler de herramienta llama al servicio correcto con los parametros esperados
- [ ] Test e2e: `POST /mcp` con token invalido retorna 401
- [ ] Test e2e: `POST /mcp` con `initialize` retorna capabilities del servidor
- [ ] Test e2e: `tools/list` retorna la lista completa de herramientas
- [ ] Test e2e: `tools/call` con `search-animals` retorna resultados correctos
- [ ] Test e2e: `tools/call` con rol insuficiente retorna error de permisos
- [ ] Probar conexion desde Claude Code usando configuracion `mcp.json` local

## Fase 6: Documentacion y Configuracion

- [ ] Agregar ejemplo de configuracion MCP en `mcp.json` del proyecto para desarrollo local
- [ ] Documentar variables de entorno necesarias (si alguna)
- [ ] Agregar seccion al README del backend explicando el endpoint MCP y como conectar un cliente
