import { Injectable, OnModuleInit, Logger, Inject } from '@nestjs/common';
import { McpServer } from '@modelcontextprotocol/sdk/server/mcp.js';
import { z } from 'zod/v4';
import { AnimalsService } from '../animals/animals.service';
import { CasasCunasService } from '../animals/casas-cunas.service';
import { SubsidiesService } from '../subsidies/subsidies.service';
import { AbuseReportsService } from '../abuse-reports/abuse-reports.service';
import { JurisdictionsService } from '../jurisdictions/jurisdictions.service';
import { STORAGE_WRAPPER } from '../captures/interfaces/storage-wrapper.interface';
import type { IStorageWrapper } from '../captures/interfaces/storage-wrapper.interface';
import { UserRole } from '../auth/roles/user-role.enum';

// User context attached to MCP requests after JWT validation
export interface McpUserContext {
  id: string;
  username: string;
  roles: UserRole[];
}

// Shared state for passing user context to tool handlers
// This is set per-request before the transport handles the message
let currentRequestUser: McpUserContext | null = null;

export function setCurrentRequestUser(user: McpUserContext | null): void {
  currentRequestUser = user;
}

function requireAuth(): McpUserContext {
  if (!currentRequestUser) {
    throw new Error('Authentication required');
  }
  return currentRequestUser;
}

function requireRoles(user: McpUserContext, allowedRoles: UserRole[]): void {
  // SUPER_USER always has access
  if (user.roles.includes(UserRole.SUPER_USER)) {
    return;
  }
  const hasRole = user.roles.some((role) => allowedRoles.includes(role));
  if (!hasRole) {
    throw new Error(
      `Acceso denegado. Se requiere uno de los siguientes roles: ${allowedRoles.join(', ')}`,
    );
  }
}

@Injectable()
export class McpService implements OnModuleInit {
  private readonly logger = new Logger(McpService.name);
  private mcpServer: McpServer;

  constructor(
    private readonly animalsService: AnimalsService,
    private readonly casasCunasService: CasasCunasService,
    private readonly subsidiesService: SubsidiesService,
    private readonly abuseReportsService: AbuseReportsService,
    private readonly jurisdictionsService: JurisdictionsService,
    @Inject(STORAGE_WRAPPER)
    private readonly captureStorage: IStorageWrapper,
  ) {}

  onModuleInit(): void {
    this.mcpServer = new McpServer({
      name: 'altrupets-backend',
      version: '1.0.0',
    });
    this.registerTools();
    this.logger.log('MCP server initialized with 6 tools');
  }

  getServer(): McpServer {
    return this.mcpServer;
  }

  private registerTools(): void {
    this.registerSearchAnimals();
    this.registerGetSubsidyStatus();
    this.registerListRescueRequests();
    this.registerGetFosterHomeCapacity();
    this.registerCreateAbuseReport();
    this.registerGetMunicipalKpis();
  }

  // -- Tool 1: search-animals (all authenticated users) --
  private registerSearchAnimals(): void {
    this.mcpServer.registerTool(
      'search-animals',
      {
        description: 'Buscar animales por especie, estado o ubicacion',
        inputSchema: z.object({
          species: z.string().optional(),
          status: z.string().optional(),
        }),
      },
      async (args) => {
        const user = requireAuth();

        let animals;
        if (args.status) {
          animals = await this.animalsService.findByStatus(args.status as any);
        } else {
          animals = await this.animalsService.findAll();
        }

        // Filter by species if provided
        if (args.species) {
          const speciesUpper = args.species.toUpperCase();
          animals = animals.filter(
            (a) => a.species?.toUpperCase() === speciesUpper,
          );
        }

        return {
          content: [
            {
              type: 'text' as const,
              text: JSON.stringify(animals, null, 2),
            },
          ],
        };
      },
    );
  }

  // -- Tool 2: get-subsidy-status (RESCUER, VETERINARIAN, GOVERNMENT_ADMIN) --
  private registerGetSubsidyStatus(): void {
    this.mcpServer.registerTool(
      'get-subsidy-status',
      {
        description: 'Consultar el estado de una solicitud de subsidio veterinario',
        inputSchema: z.object({
          subsidyRequestId: z.string(),
        }),
      },
      async (args) => {
        const user = requireAuth();
        requireRoles(user, [
          UserRole.RESCUER,
          UserRole.VETERINARIAN,
          UserRole.GOVERNMENT_ADMIN,
        ]);

        const subsidy = await this.subsidiesService.findOne(
          args.subsidyRequestId,
        );

        return {
          content: [
            {
              type: 'text' as const,
              text: JSON.stringify(subsidy, null, 2),
            },
          ],
        };
      },
    );
  }

  // -- Tool 3: list-rescue-requests (RESCUER, HELPER, GOVERNMENT_ADMIN) --
  private registerListRescueRequests(): void {
    this.mcpServer.registerTool(
      'list-rescue-requests',
      {
        description: 'Listar solicitudes de rescate activas',
        inputSchema: z.object({
          status: z.string().optional(),
          limit: z.number().optional(),
        }),
      },
      async (args) => {
        const user = requireAuth();
        requireRoles(user, [
          UserRole.RESCUER,
          UserRole.HELPER,
          UserRole.GOVERNMENT_ADMIN,
        ]);

        let captures = await this.captureStorage.getCaptures();

        // Filter by status if provided
        if (args.status) {
          const statusUpper = args.status.toUpperCase();
          captures = captures.filter(
            (c) => c.status?.toUpperCase() === statusUpper,
          );
        }

        // Apply limit if provided
        if (args.limit && args.limit > 0) {
          captures = captures.slice(0, args.limit);
        }

        return {
          content: [
            {
              type: 'text' as const,
              text: JSON.stringify(captures, null, 2),
            },
          ],
        };
      },
    );
  }

  // -- Tool 4: get-foster-home-capacity (RESCUER, HELPER, GOVERNMENT_ADMIN) --
  private registerGetFosterHomeCapacity(): void {
    this.mcpServer.registerTool(
      'get-foster-home-capacity',
      {
        description: 'Verificar disponibilidad de casas cuna por zona',
        inputSchema: z.object({
          jurisdictionId: z.string().optional(),
        }),
      },
      async (args) => {
        const user = requireAuth();
        requireRoles(user, [
          UserRole.RESCUER,
          UserRole.HELPER,
          UserRole.GOVERNMENT_ADMIN,
        ]);

        const casasCunas = await this.casasCunasService.findAll();

        const capacityData = casasCunas.map((cc) => ({
          id: cc.id,
          name: cc.name,
          province: cc.province,
          canton: cc.canton,
          district: cc.district,
          capacity: cc.capacity ?? 0,
          currentCount: cc.currentCount ?? 0,
          available: (cc.capacity ?? 0) - (cc.currentCount ?? 0),
          isVerified: cc.isVerified,
        }));

        return {
          content: [
            {
              type: 'text' as const,
              text: JSON.stringify(capacityData, null, 2),
            },
          ],
        };
      },
    );
  }

  // -- Tool 5: create-abuse-report (all authenticated users) --
  private registerCreateAbuseReport(): void {
    this.mcpServer.registerTool(
      'create-abuse-report',
      {
        description: 'Registrar una denuncia de maltrato animal',
        inputSchema: z.object({
          description: z.string(),
          location: z.object({
            lat: z.number(),
            lng: z.number(),
          }),
          type: z.string(),
        }),
      },
      async (args) => {
        const user = requireAuth();

        const report = await this.abuseReportsService.create({
          type: args.type,
          description: args.description,
          latitude: args.location.lat,
          longitude: args.location.lng,
          reporterId: user.id,
        });

        return {
          content: [
            {
              type: 'text' as const,
              text: JSON.stringify(report, null, 2),
            },
          ],
        };
      },
    );
  }

  // -- Tool 6: get-municipal-kpis (GOVERNMENT_ADMIN only) --
  private registerGetMunicipalKpis(): void {
    this.mcpServer.registerTool(
      'get-municipal-kpis',
      {
        description: 'Obtener KPIs del dashboard municipal por jurisdiccion',
        inputSchema: z.object({
          jurisdictionId: z.string(),
        }),
      },
      async (args) => {
        const user = requireAuth();
        requireRoles(user, [UserRole.GOVERNMENT_ADMIN]);

        // Fetch jurisdiction info
        const jurisdiction = await this.jurisdictionsService.findOne(
          args.jurisdictionId,
        );

        // Aggregate KPI data from multiple sources
        const casasCunas = await this.casasCunasService.findAll();
        const animals = await this.animalsService.findAll();

        const totalCapacity = casasCunas.reduce(
          (sum, cc) => sum + (cc.capacity ?? 0),
          0,
        );
        const totalOccupied = casasCunas.reduce(
          (sum, cc) => sum + (cc.currentCount ?? 0),
          0,
        );

        const kpis = {
          jurisdiction: {
            id: jurisdiction.id,
            name: jurisdiction.name,
          },
          fosterHomes: {
            total: casasCunas.length,
            totalCapacity,
            totalOccupied,
            occupancyRate:
              totalCapacity > 0
                ? Math.round((totalOccupied / totalCapacity) * 100)
                : 0,
          },
          animals: {
            total: animals.length,
            rescued: animals.filter((a) => a.status === 'RESCUED').length,
            inCasaCuna: animals.filter((a) => a.status === 'IN_CASA_CUNA')
              .length,
            adopted: animals.filter((a) => a.status === 'ADOPTED').length,
          },
        };

        return {
          content: [
            {
              type: 'text' as const,
              text: JSON.stringify(kpis, null, 2),
            },
          ],
        };
      },
    );
  }
}
