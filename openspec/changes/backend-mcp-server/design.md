# Diseno: Servidor MCP en Backend NestJS

**Change ID**: `backend-mcp-server`
**Servicios afectados**: AppModule, AuthModule, nuevo McpModule

---

## 1. Arquitectura General

El servidor MCP se implementa como un modulo NestJS independiente (`McpModule`) que registra herramientas y expone un endpoint HTTP. Las herramientas delegan la logica a los servicios existentes del backend.

```
┌─────────────────────────────────────────────────────┐
│              Cliente MCP (Claude Code, AI Agent)      │
│              POST /mcp  (Authorization: Bearer JWT)  │
└──────────────────────┬──────────────────────────────┘
                       │ Streamable HTTP
┌──────────────────────▼──────────────────────────────┐
│                  McpController                        │
│  POST /mcp -> StreamableHTTPServerTransport           │
│  Valida JWT antes de procesar mensajes MCP           │
├─────────────────────────────────────────────────────┤
│                  McpService                           │
│  Inicializa McpServer con metadata del servidor      │
│  Registra herramientas (tools) con schemas            │
│  Cada tool invoca el servicio NestJS correspondiente │
├─────────────────────────────────────────────────────┤
│               Tool Handlers                           │
│  search-animals       -> AnimalsService               │
│  get-subsidy-status   -> SubsidiesService             │
│  list-rescue-requests -> CapturesService              │
│  get-foster-home-capacity -> (UsersService/query)     │
│  create-abuse-report  -> AbuseReportsService          │
│  get-municipal-kpis   -> (GovernmentService/query)    │
├─────────────────────────────────────────────────────┤
│         Servicios existentes del backend             │
│  AnimalsService, SubsidiesService, CapturesService,  │
│  AbuseReportsService, UsersService                   │
└─────────────────────────────────────────────────────┘
```

## 2. McpModule

### Estructura de archivos

```
src/mcp/
  mcp.module.ts
  mcp.controller.ts
  mcp.service.ts
  tools/
    search-animals.tool.ts
    get-subsidy-status.tool.ts
    list-rescue-requests.tool.ts
    get-foster-home-capacity.tool.ts
    create-abuse-report.tool.ts
    get-municipal-kpis.tool.ts
  interfaces/
    mcp-tool.interface.ts
```

### Modulo

```typescript
// src/mcp/mcp.module.ts
@Module({
  imports: [
    AnimalsModule,
    SubsidiesModule,
    CapturesModule,
    AbuseReportsModule,
    UsersModule,
    AuthModule,
  ],
  controllers: [McpController],
  providers: [McpService],
})
export class McpModule {}
```

## 3. McpService — Inicializacion y Registro de Herramientas

```typescript
// src/mcp/mcp.service.ts
import { McpServer } from '@modelcontextprotocol/sdk/server/mcp.js';
import { z } from 'zod';

@Injectable()
export class McpService implements OnModuleInit {
  private server: McpServer;

  constructor(
    private readonly animalsService: AnimalsService,
    private readonly subsidiesService: SubsidiesService,
    private readonly capturesService: CapturesService,
    private readonly abuseReportsService: AbuseReportsService,
    // ... otros servicios
  ) {}

  onModuleInit() {
    this.server = new McpServer({
      name: 'altrupets-backend',
      version: '1.0.0',
    });

    this.registerTools();
  }

  getServer(): McpServer {
    return this.server;
  }

  private registerTools() {
    this.registerSearchAnimals();
    this.registerGetSubsidyStatus();
    this.registerListRescueRequests();
    this.registerGetFosterHomeCapacity();
    this.registerCreateAbuseReport();
    this.registerGetMunicipalKpis();
  }

  // ... metodos de registro individuales (ver seccion 5)
}
```

## 4. McpController — Transporte Streamable HTTP

```typescript
// src/mcp/mcp.controller.ts
import { StreamableHTTPServerTransport } from '@modelcontextprotocol/sdk/server/streamableHttp.js';

@Controller('mcp')
export class McpController {
  constructor(
    private readonly mcpService: McpService,
    private readonly authService: AuthService,
  ) {}

  @Post()
  async handleMcp(
    @Req() req: Request,
    @Res() res: Response,
  ) {
    // 1. Validar JWT del header Authorization
    const authHeader = req.headers['authorization'];
    if (!authHeader?.startsWith('Bearer ')) {
      return res.status(401).json({ error: 'Token JWT requerido' });
    }

    const token = authHeader.substring(7);
    try {
      await this.authService.validateToken(token);
    } catch {
      return res.status(401).json({ error: 'Token invalido o expirado' });
    }

    // 2. Crear transporte y conectar al servidor MCP
    const transport = new StreamableHTTPServerTransport({
      sessionIdGenerator: undefined, // Stateless — sin gestion de sesiones
    });

    await this.mcpService.getServer().connect(transport);

    // 3. Delegar el manejo del request al transporte
    await transport.handleRequest(req, res);
  }
}
```

### Consideracion: Stateless vs Stateful

Se configura `sessionIdGenerator: undefined` para modo stateless. Cada request es independiente. Esto simplifica el despliegue en multiples replicas (Kubernetes) sin necesidad de sticky sessions. Si en el futuro se necesitan sesiones MCP persistentes, se puede agregar un generador de session ID con almacenamiento en Redis.

## 5. Definicion de Herramientas (Tools)

### 5.1 search-animals

```typescript
private registerSearchAnimals() {
  this.server.tool(
    'search-animals',
    'Buscar animales en la plataforma por especie, estado, ubicacion u otros criterios',
    {
      species: z.enum(['GATO', 'PERRO', 'OTRO']).optional()
        .describe('Especie del animal'),
      status: z.enum(['RESCUED', 'IN_FOSTER', 'AVAILABLE_FOR_ADOPTION', 'ADOPTED'])
        .optional().describe('Estado actual del animal'),
      latitude: z.number().optional()
        .describe('Latitud para busqueda por proximidad'),
      longitude: z.number().optional()
        .describe('Longitud para busqueda por proximidad'),
      radiusKm: z.number().default(10).optional()
        .describe('Radio de busqueda en km (default: 10)'),
      limit: z.number().default(20).optional()
        .describe('Numero maximo de resultados'),
    },
    async (params) => {
      const animals = await this.animalsService.search(params);
      return {
        content: [{
          type: 'text' as const,
          text: JSON.stringify(animals, null, 2),
        }],
      };
    },
  );
}
```

### 5.2 get-subsidy-status

```typescript
private registerGetSubsidyStatus() {
  this.server.tool(
    'get-subsidy-status',
    'Consultar el estado de una solicitud de subvencion veterinaria municipal',
    {
      subsidyId: z.string().uuid()
        .describe('ID de la solicitud de subvencion'),
    },
    async (params) => {
      const subsidy = await this.subsidiesService.findById(params.subsidyId);
      if (!subsidy) {
        return {
          content: [{ type: 'text' as const, text: 'Solicitud no encontrada' }],
          isError: true,
        };
      }
      return {
        content: [{
          type: 'text' as const,
          text: JSON.stringify(subsidy, null, 2),
        }],
      };
    },
  );
}
```

### 5.3 list-rescue-requests

```typescript
private registerListRescueRequests() {
  this.server.tool(
    'list-rescue-requests',
    'Listar solicitudes de rescate activas, opcionalmente filtradas por estado o zona',
    {
      status: z.enum(['PENDING', 'ACCEPTED', 'IN_PROGRESS', 'COMPLETED'])
        .optional().describe('Estado de la solicitud de rescate'),
      latitude: z.number().optional()
        .describe('Latitud para filtrar por zona'),
      longitude: z.number().optional()
        .describe('Longitud para filtrar por zona'),
      radiusKm: z.number().default(25).optional()
        .describe('Radio de busqueda en km'),
      limit: z.number().default(20).optional()
        .describe('Numero maximo de resultados'),
    },
    async (params) => {
      const requests = await this.capturesService.findActive(params);
      return {
        content: [{
          type: 'text' as const,
          text: JSON.stringify(requests, null, 2),
        }],
      };
    },
  );
}
```

### 5.4 get-foster-home-capacity

```typescript
private registerGetFosterHomeCapacity() {
  this.server.tool(
    'get-foster-home-capacity',
    'Verificar la disponibilidad y capacidad de casas cuna en una zona',
    {
      latitude: z.number()
        .describe('Latitud del punto de referencia'),
      longitude: z.number()
        .describe('Longitud del punto de referencia'),
      radiusKm: z.number().default(15).optional()
        .describe('Radio de busqueda en km'),
      species: z.enum(['GATO', 'PERRO', 'OTRO']).optional()
        .describe('Filtrar por especie que aceptan'),
    },
    async (params) => {
      // Consulta a rescatistas con casa cuna en la zona
      const homes = await this.usersService.findFosterHomes(params);
      return {
        content: [{
          type: 'text' as const,
          text: JSON.stringify(homes, null, 2),
        }],
      };
    },
  );
}
```

### 5.5 create-abuse-report

```typescript
private registerCreateAbuseReport() {
  this.server.tool(
    'create-abuse-report',
    'Registrar una denuncia de maltrato animal (requiere autenticacion, no anonima — regla SRD #9)',
    {
      description: z.string().min(10)
        .describe('Descripcion detallada del incidente'),
      latitude: z.number()
        .describe('Latitud de la ubicacion del incidente'),
      longitude: z.number()
        .describe('Longitud de la ubicacion del incidente'),
      animalSpecies: z.enum(['GATO', 'PERRO', 'OTRO']).optional()
        .describe('Especie del animal afectado'),
      urgency: z.enum(['LOW', 'MEDIUM', 'HIGH', 'CRITICAL']).default('MEDIUM')
        .describe('Nivel de urgencia'),
    },
    async (params) => {
      // El userId se obtiene del JWT validado en el controller
      const report = await this.abuseReportsService.create(params);
      return {
        content: [{
          type: 'text' as const,
          text: JSON.stringify({ id: report.id, status: report.status }, null, 2),
        }],
      };
    },
  );
}
```

### 5.6 get-municipal-kpis

```typescript
private registerGetMunicipalKpis() {
  this.server.tool(
    'get-municipal-kpis',
    'Obtener KPIs del dashboard municipal para una jurisdiccion (animales rescatados, subvenciones, denuncias, etc.)',
    {
      jurisdictionId: z.string().uuid()
        .describe('ID de la jurisdiccion/municipalidad'),
      period: z.enum(['WEEK', 'MONTH', 'QUARTER', 'YEAR']).default('MONTH')
        .describe('Periodo de tiempo para los KPIs'),
    },
    async (params) => {
      // Consulta agregada de KPIs por jurisdiccion
      const kpis = await this.governmentService.getKpis(
        params.jurisdictionId,
        params.period,
      );
      return {
        content: [{
          type: 'text' as const,
          text: JSON.stringify(kpis, null, 2),
        }],
      };
    },
  );
}
```

## 6. Seguridad

### Autenticacion JWT

El endpoint `POST /mcp` requiere un token JWT valido en el header `Authorization: Bearer <token>`. Se reutiliza `AuthService.validateToken()` que ya existe en el backend.

```
POST /mcp HTTP/1.1
Authorization: Bearer eyJhbGciOiJIUzI1NiIs...
Content-Type: application/json

{"jsonrpc":"2.0","method":"tools/call","params":{"name":"search-animals","arguments":{"species":"PERRO"}},"id":1}
```

### RBAC en herramientas

Cada herramienta puede verificar los roles del usuario autenticado:

| Tool | Roles permitidos |
|------|-----------------|
| `search-animals` | Todos los roles autenticados |
| `get-subsidy-status` | RESCUER, VET, GOVERNMENT_ADMIN |
| `list-rescue-requests` | RESCUER, AUXILIARY, GOVERNMENT_ADMIN |
| `get-foster-home-capacity` | Todos los roles autenticados |
| `create-abuse-report` | Todos los roles autenticados (no anonimo) |
| `get-municipal-kpis` | GOVERNMENT_ADMIN |

### Propagacion de contexto de usuario

El JWT decodificado se pasa como contexto a los handlers de las herramientas para que puedan aplicar RBAC y filtrado por jurisdiccion. Esto se logra inyectando el usuario en el request antes de conectar el transporte.

### Rate limiting

El endpoint `POST /mcp` se protege con el `ThrottlerModule` existente (100 req/min por defecto). Se puede configurar un throttle especifico mas restrictivo para el MCP si es necesario.

### Proteccion contra herramientas destructivas

Solo `create-abuse-report` tiene capacidad de escritura. Las demas herramientas son de solo lectura. No se exponen herramientas de eliminacion o modificacion de datos sensibles.

## 7. Configuracion de Transporte

### Streamable HTTP

Se usa `StreamableHTTPServerTransport` del SDK oficial. Esta es la interfaz de transporte recomendada para servidores HTTP, reemplazando al antiguo SSE transport.

Caracteristicas:
- Soporta request/response y streaming en un solo endpoint POST
- Compatible con cualquier cliente MCP moderno
- Stateless por defecto (no requiere gestion de sesiones)
- Se integra directamente con Express (subyacente a NestJS)

### Endpoint unico

```
POST /mcp — Maneja todos los mensajes MCP (initialize, tools/list, tools/call, etc.)
```

No se implementan endpoints adicionales como GET o DELETE ya que el modo stateless no requiere gestion de sesiones.

## 8. Configuracion del cliente MCP (Claude Code)

Para que Claude Code use el servidor MCP de AltruPets, se agrega al archivo `mcp.json` del proyecto:

```json
{
  "mcpServers": {
    "altrupets-backend": {
      "type": "url",
      "url": "http://localhost:3000/mcp",
      "headers": {
        "Authorization": "Bearer <JWT_TOKEN>"
      }
    }
  }
}
```

## 9. Patron de Registro de Herramientas

Cada herramienta sigue el patron:

1. **Nombre**: Kebab-case descriptivo (`search-animals`, no `searchAnimals`)
2. **Descripcion**: En espanol, explica que hace y cuando usarla
3. **Parametros**: Definidos con Zod schemas, cada uno con `.describe()` en espanol
4. **Handler**: Delega al servicio NestJS existente, nunca accede a la BD directamente
5. **Respuesta**: Siempre retorna `{ content: [{ type: 'text', text: JSON }] }` para compatibilidad universal

Este patron facilita agregar nuevas herramientas en el futuro simplemente creando un nuevo metodo `registerXxx()` en `McpService`.
