import { Injectable, Logger, NotFoundException, BadRequestException } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository, LessThan, In } from 'typeorm';
import { SubsidyRequest, SubsidyRequestStatus } from './entities/subsidy-request.entity';
import { AutoApprovalRule } from './entities/auto-approval-rule.entity';
import { ApprovalAuditLog } from './entities/approval-audit-log.entity';
import { AutoApprovalEngineService, EngineContext } from './auto-approval-engine.service';
import { JurisdictionsService } from '../jurisdictions/jurisdictions.service';
import { Animal } from '../animals/entities/animal.entity';
import { User } from '../users/entities/user.entity';
import { VetProfile } from '../vet-profiles/entities/vet-profile.entity';
import { NotificationsService } from '../notifications/notifications.service';
import { NotificationType } from '../notifications/enums/notification-type.enum';
import { UserRole } from '../auth/roles/user-role.enum';
import { AuditAction } from './enums/audit-action.enum';
import { CreateVetSubsidyRequestInput } from './dto/create-vet-subsidy-request.input';
import { SubsidyFiltersInput } from './dto/subsidy-filters.input';
import { BudgetStatus } from './dto/budget-status.output';
import { UpsertAutoApprovalRuleInput } from './dto/upsert-auto-approval-rule.input';

@Injectable()
export class SubsidiesService {
  private readonly logger = new Logger(SubsidiesService.name);
  private trackingCodeCounter = 0;

  constructor(
    @InjectRepository(SubsidyRequest)
    private readonly subsidyRepository: Repository<SubsidyRequest>,
    @InjectRepository(Animal)
    private readonly animalRepository: Repository<Animal>,
    @InjectRepository(User)
    private readonly userRepository: Repository<User>,
    @InjectRepository(VetProfile)
    private readonly vetProfileRepository: Repository<VetProfile>,
    @InjectRepository(AutoApprovalRule)
    private readonly ruleRepository: Repository<AutoApprovalRule>,
    @InjectRepository(ApprovalAuditLog)
    private readonly auditLogRepository: Repository<ApprovalAuditLog>,
    private readonly jurisdictionsService: JurisdictionsService,
    private readonly notificationsService: NotificationsService,
    private readonly autoApprovalEngine: AutoApprovalEngineService,
  ) {}

  // ─── Legacy create (kept for backward compatibility) ─────────────

  async create(data: {
    animalId: string;
    requesterId: string;
    amountRequested: number;
    justification: string;
  }): Promise<SubsidyRequest> {
    // 1. Validate animal existence and location
    const animal = await this.animalRepository.findOne({ where: { id: data.animalId } });
    if (!animal) {
      throw new NotFoundException(`Animal with ID ${data.animalId} not found`);
    }

    if (!animal.location) {
        throw new BadRequestException('Animal must have a location to request a subsidy');
    }

    // 2. Find municipality by animal location
    const [longitude, latitude] = animal.location.coordinates;
    const jurisdiction = await this.jurisdictionsService.findByCoordinates(latitude, longitude);

    // 3. Create request
    const request = this.subsidyRepository.create({
      animalId: data.animalId,
      requesterId: data.requesterId,
      amountRequested: data.amountRequested,
      justification: data.justification,
      municipalityId: jurisdiction?.organizationId,
      status: SubsidyRequestStatus.CREATED,
      expiresAt: new Date(Date.now() + 72 * 60 * 60 * 1000), // 72 hours expiration
    });

    const saved = await this.subsidyRepository.save(request);

    // Notify government admins about new subsidy request
    this.notificationsService
      .sendToRole({
        role: UserRole.GOVERNMENT_ADMIN,
        type: NotificationType.SUBSIDY_CREATED,
        title: 'New Subsidy Request',
        body: `A new subsidy request has been submitted for $${data.amountRequested}`,
        referenceId: saved.id,
        referenceType: 'SubsidyRequest',
        jurisdictionId: saved.municipalityId,
      })
      .catch((err) => this.logger.warn('Notification send failed', err));

    return saved;
  }

  // ─── ALT-64: Create Vet Subsidy Request with auto-approval ──────

  async createVetSubsidyRequest(
    requesterId: string,
    input: CreateVetSubsidyRequestInput,
  ): Promise<SubsidyRequest> {
    // 1. Validate animal
    const animal = await this.animalRepository.findOne({ where: { id: input.animalId } });
    if (!animal) {
      throw new NotFoundException(`Animal with ID ${input.animalId} not found`);
    }

    if (!animal.location) {
      throw new BadRequestException('Animal must have a location to request a subsidy');
    }

    // 2. Load requester
    const requester = await this.userRepository.findOne({ where: { id: requesterId } });
    if (!requester) {
      throw new NotFoundException(`User with ID ${requesterId} not found`);
    }

    // 3. Load vet profile if provided
    let vetProfile: VetProfile | undefined;
    if (input.vetProfileId) {
      const vp = await this.vetProfileRepository.findOne({ where: { id: input.vetProfileId } });
      if (!vp) {
        throw new NotFoundException(`Vet profile with ID ${input.vetProfileId} not found`);
      }
      vetProfile = vp;
    }

    // 4. Find municipality
    const [longitude, latitude] = animal.location.coordinates;
    const jurisdiction = await this.jurisdictionsService.findByCoordinates(latitude, longitude);
    const municipalityId = jurisdiction?.organizationId;

    // 5. Generate tracking code
    const trackingCode = this.generateTrackingCode();

    // 6. Create request
    const request = this.subsidyRepository.create({
      animalId: input.animalId,
      requesterId,
      amountRequested: input.amountRequested,
      justification: input.justification,
      vetProfileId: input.vetProfileId,
      procedureType: input.procedureType,
      municipalityId,
      trackingCode,
      status: SubsidyRequestStatus.CREATED,
      expiresAt: new Date(Date.now() + 72 * 60 * 60 * 1000),
    });

    const saved = await this.subsidyRepository.save(request);

    // 7. Run auto-approval engine
    if (municipalityId) {
      const context: EngineContext = {
        request: saved,
        requester,
        animal,
        vetProfile,
        municipalityId,
      };

      const ruleResults = await this.autoApprovalEngine.evaluate(context);
      const allPassed = this.autoApprovalEngine.allPassed(ruleResults);

      if (allPassed) {
        // Auto-approve
        saved.status = SubsidyRequestStatus.APPROVED;
        saved.autoApproved = true;
        saved.reviewedAt = new Date();
        await this.subsidyRepository.save(saved);

        // Log audit
        await this.createAuditLog({
          subsidyRequestId: saved.id,
          action: AuditAction.AUTO_APPROVED,
          ruleResults: ruleResults.map((r) => ({ ...r })),
          previousStatus: SubsidyRequestStatus.CREATED,
          newStatus: SubsidyRequestStatus.APPROVED,
        });

        // Notify requester of approval
        this.notifyApproval(saved).catch(() => {});
      } else {
        // Send to manual review
        saved.status = SubsidyRequestStatus.IN_REVIEW;
        saved.autoApproved = false;
        await this.subsidyRepository.save(saved);

        // Log audit
        await this.createAuditLog({
          subsidyRequestId: saved.id,
          action: AuditAction.SENT_TO_REVIEW,
          ruleResults: ruleResults.map((r) => ({ ...r })),
          previousStatus: SubsidyRequestStatus.CREATED,
          newStatus: SubsidyRequestStatus.IN_REVIEW,
        });

        // Notify government admins for manual review
        this.notificationsService
          .sendToRole({
            role: UserRole.GOVERNMENT_ADMIN,
            type: NotificationType.SUBSIDY_CREATED,
            title: 'Nueva solicitud de desembolso veterinario',
            body: `Solicitud ${trackingCode} requiere revision manual — ${this.formatCRC(input.amountRequested)}`,
            referenceId: saved.id,
            referenceType: 'SubsidyRequest',
            jurisdictionId: municipalityId,
          })
          .catch((err) => this.logger.warn('Notification send failed', err));
      }
    }

    return this.findOne(saved.id);
  }

  // ─── ALT-64: Manual approve/reject ──────────────────────────────

  async approveSubsidyRequest(
    id: string,
    reviewerId: string,
    notes?: string,
  ): Promise<SubsidyRequest> {
    const request = await this.findOne(id);

    if (![SubsidyRequestStatus.CREATED, SubsidyRequestStatus.IN_REVIEW].includes(request.status)) {
      throw new BadRequestException(
        `Cannot approve a request in status ${request.status}`,
      );
    }

    const previousStatus = request.status;
    request.status = SubsidyRequestStatus.APPROVED;
    request.reviewedById = reviewerId;
    request.reviewedAt = new Date();
    request.autoApproved = false;

    const saved = await this.subsidyRepository.save(request);

    await this.createAuditLog({
      subsidyRequestId: saved.id,
      actorId: reviewerId,
      action: AuditAction.MANUAL_APPROVED,
      previousStatus,
      newStatus: SubsidyRequestStatus.APPROVED,
      notes,
    });

    this.notifyApproval(saved).catch(() => {});
    return this.findOne(saved.id);
  }

  async rejectSubsidyRequest(
    id: string,
    reviewerId: string,
    rejectionReason: string,
    notes?: string,
  ): Promise<SubsidyRequest> {
    const request = await this.findOne(id);

    if (![SubsidyRequestStatus.CREATED, SubsidyRequestStatus.IN_REVIEW].includes(request.status)) {
      throw new BadRequestException(
        `Cannot reject a request in status ${request.status}`,
      );
    }

    const previousStatus = request.status;
    request.status = SubsidyRequestStatus.REJECTED;
    request.reviewedById = reviewerId;
    request.reviewedAt = new Date();
    request.rejectionReason = rejectionReason;

    const saved = await this.subsidyRepository.save(request);

    await this.createAuditLog({
      subsidyRequestId: saved.id,
      actorId: reviewerId,
      action: AuditAction.REJECTED,
      previousStatus,
      newStatus: SubsidyRequestStatus.REJECTED,
      notes,
    });

    this.notificationsService
      .sendToUser({
        userId: saved.requesterId,
        type: NotificationType.SUBSIDY_REJECTED,
        title: 'Solicitud de desembolso rechazada',
        body: `Su solicitud ${saved.trackingCode ?? saved.id} ha sido rechazada: ${rejectionReason}`,
        referenceId: saved.id,
        referenceType: 'SubsidyRequest',
      })
      .catch(() => {});

    return this.findOne(saved.id);
  }

  // ─── Queries ────────────────────────────────────────────────────

  async findOne(id: string): Promise<SubsidyRequest> {
    const request = await this.subsidyRepository.findOne({
      where: { id },
      relations: ['animal', 'requester', 'municipality', 'vetProfile', 'reviewedBy'],
    });
    if (!request) {
      throw new NotFoundException(`Subsidy request with ID ${id} not found`);
    }
    return request;
  }

  async findAllByRequester(requesterId: string): Promise<SubsidyRequest[]> {
    return this.subsidyRepository.find({
      where: { requesterId },
      order: { createdAt: 'DESC' },
    });
  }

  async findPending(filters?: SubsidyFiltersInput): Promise<SubsidyRequest[]> {
    const qb = this.subsidyRepository
      .createQueryBuilder('sr')
      .leftJoinAndSelect('sr.animal', 'animal')
      .leftJoinAndSelect('sr.requester', 'requester')
      .leftJoinAndSelect('sr.municipality', 'municipality')
      .leftJoinAndSelect('sr.vetProfile', 'vetProfile')
      .where('sr.status IN (:...statuses)', {
        statuses: [SubsidyRequestStatus.CREATED, SubsidyRequestStatus.IN_REVIEW],
      })
      .orderBy('sr.createdAt', 'DESC');

    if (filters?.municipalityId) {
      qb.andWhere('sr.municipalityId = :municipalityId', {
        municipalityId: filters.municipalityId,
      });
    }
    if (filters?.dateFrom) {
      qb.andWhere('sr.createdAt >= :dateFrom', { dateFrom: filters.dateFrom });
    }
    if (filters?.dateTo) {
      qb.andWhere('sr.createdAt <= :dateTo', { dateTo: filters.dateTo });
    }

    return qb.getMany();
  }

  async findApproved(filters?: SubsidyFiltersInput): Promise<SubsidyRequest[]> {
    const qb = this.subsidyRepository
      .createQueryBuilder('sr')
      .leftJoinAndSelect('sr.animal', 'animal')
      .leftJoinAndSelect('sr.requester', 'requester')
      .leftJoinAndSelect('sr.municipality', 'municipality')
      .leftJoinAndSelect('sr.vetProfile', 'vetProfile')
      .leftJoinAndSelect('sr.reviewedBy', 'reviewedBy')
      .where('sr.status IN (:...statuses)', {
        statuses: [SubsidyRequestStatus.APPROVED, SubsidyRequestStatus.PAID],
      })
      .orderBy('sr.createdAt', 'DESC');

    if (filters?.municipalityId) {
      qb.andWhere('sr.municipalityId = :municipalityId', {
        municipalityId: filters.municipalityId,
      });
    }
    if (filters?.dateFrom) {
      qb.andWhere('sr.createdAt >= :dateFrom', { dateFrom: filters.dateFrom });
    }
    if (filters?.dateTo) {
      qb.andWhere('sr.createdAt <= :dateTo', { dateTo: filters.dateTo });
    }

    return qb.getMany();
  }

  async getBudgetStatus(municipalityId: string): Promise<BudgetStatus> {
    const now = new Date();
    const monthStart = new Date(now.getFullYear(), now.getMonth(), 1);
    const monthEnd = new Date(now.getFullYear(), now.getMonth() + 1, 0, 23, 59, 59, 999);

    // Get monthly budget from WITHIN_BUDGET rule parameters, or default
    const budgetRule = await this.ruleRepository.findOne({
      where: { municipalityId, ruleType: 'WITHIN_BUDGET' as any },
    });
    const monthlyBudget = budgetRule?.parameters?.monthlyBudget ?? 500000;

    // Count requests by status
    const counts = await this.subsidyRepository
      .createQueryBuilder('sr')
      .select('sr.status', 'status')
      .addSelect('COUNT(*)', 'count')
      .addSelect('COALESCE(SUM(sr.amountRequested), 0)', 'total')
      .where('sr.municipalityId = :municipalityId', { municipalityId })
      .andWhere('sr.createdAt BETWEEN :start AND :end', {
        start: monthStart,
        end: monthEnd,
      })
      .groupBy('sr.status')
      .getRawMany();

    let disbursed = 0;
    let totalRequests = 0;
    let approvedCount = 0;
    let inReviewCount = 0;
    let rejectedCount = 0;

    for (const row of counts) {
      const count = parseInt(row.count, 10);
      totalRequests += count;

      switch (row.status) {
        case SubsidyRequestStatus.APPROVED:
        case SubsidyRequestStatus.PAID:
          approvedCount += count;
          disbursed += parseFloat(row.total);
          break;
        case SubsidyRequestStatus.IN_REVIEW:
        case SubsidyRequestStatus.CREATED:
          inReviewCount += count;
          break;
        case SubsidyRequestStatus.REJECTED:
          rejectedCount += count;
          break;
      }
    }

    const available = Math.max(0, monthlyBudget - disbursed);
    const usagePercent = monthlyBudget > 0 ? (disbursed / monthlyBudget) * 100 : 0;
    const daysRemainingInMonth = Math.ceil(
      (monthEnd.getTime() - now.getTime()) / (1000 * 60 * 60 * 24),
    );

    return {
      monthlyBudget,
      disbursed,
      available,
      usagePercent: Math.round(usagePercent * 100) / 100,
      totalRequests,
      approvedCount,
      inReviewCount,
      rejectedCount,
      daysRemainingInMonth,
    };
  }

  // ─── Audit log ──────────────────────────────────────────────────

  async getAuditLog(subsidyRequestId: string): Promise<ApprovalAuditLog[]> {
    return this.auditLogRepository.find({
      where: { subsidyRequestId },
      relations: ['actor'],
      order: { createdAt: 'DESC' },
    });
  }

  // ─── Auto-approval rules management ─────────────────────────────

  async getApprovalRules(municipalityId: string): Promise<AutoApprovalRule[]> {
    return this.ruleRepository.find({
      where: { municipalityId },
      order: { ruleType: 'ASC' },
    });
  }

  async upsertAutoApprovalRule(input: UpsertAutoApprovalRuleInput): Promise<AutoApprovalRule> {
    const existing = await this.ruleRepository.findOne({
      where: {
        municipalityId: input.municipalityId,
        ruleType: input.ruleType,
      },
    });

    if (existing) {
      existing.isEnabled = input.isEnabled;
      if (input.parameters !== undefined) {
        existing.parameters = input.parameters;
      }
      return this.ruleRepository.save(existing);
    }

    const rule = this.ruleRepository.create({
      municipalityId: input.municipalityId,
      ruleType: input.ruleType,
      isEnabled: input.isEnabled,
      parameters: input.parameters,
    });
    return this.ruleRepository.save(rule);
  }

  async toggleApprovalRule(
    ruleId: string,
    isEnabled: boolean,
  ): Promise<AutoApprovalRule> {
    const rule = await this.ruleRepository.findOne({ where: { id: ruleId } });
    if (!rule) {
      throw new NotFoundException(`Auto-approval rule with ID ${ruleId} not found`);
    }
    rule.isEnabled = isEnabled;
    return this.ruleRepository.save(rule);
  }

  // ─── Legacy status update (kept for backward compatibility) ─────

  async updateStatus(id: string, status: SubsidyRequestStatus): Promise<SubsidyRequest> {
    const request = await this.findOne(id);
    request.status = status;
    const saved = await this.subsidyRepository.save(request);

    // Send notification to the requester based on status change
    const notificationMap: Partial<Record<SubsidyRequestStatus, { type: NotificationType; title: string; body: string }>> = {
      [SubsidyRequestStatus.APPROVED]: {
        type: NotificationType.SUBSIDY_APPROVED,
        title: 'Subsidy Request Approved',
        body: 'Your subsidy request has been approved',
      },
      [SubsidyRequestStatus.REJECTED]: {
        type: NotificationType.SUBSIDY_REJECTED,
        title: 'Subsidy Request Rejected',
        body: 'Your subsidy request has been rejected',
      },
    };

    const notificationConfig = notificationMap[status];
    if (notificationConfig) {
      this.notificationsService
        .sendToUser({
          userId: saved.requesterId,
          type: notificationConfig.type,
          title: notificationConfig.title,
          body: notificationConfig.body,
          referenceId: saved.id,
          referenceType: 'SubsidyRequest',
        })
        .catch(() => {
          // Notification failures should not block the main flow
        });
    }

    return saved;
  }

  async expireOldRequests(): Promise<number> {
    const result = await this.subsidyRepository.update(
      {
        status: SubsidyRequestStatus.CREATED,
        expiresAt: LessThan(new Date()),
      },
      { status: SubsidyRequestStatus.EXPIRED },
    );
    return result.affected || 0;
  }

  // ─── Private helpers ────────────────────────────────────────────

  private async createAuditLog(data: {
    subsidyRequestId: string;
    actorId?: string;
    action: AuditAction;
    ruleResults?: Record<string, any>[];
    previousStatus?: SubsidyRequestStatus;
    newStatus?: SubsidyRequestStatus;
    notes?: string;
  }): Promise<ApprovalAuditLog> {
    const log = this.auditLogRepository.create({
      subsidyRequestId: data.subsidyRequestId,
      actorId: data.actorId,
      action: data.action,
      ruleResults: data.ruleResults as any,
      previousStatus: data.previousStatus,
      newStatus: data.newStatus,
      notes: data.notes,
    });
    return this.auditLogRepository.save(log);
  }

  private async notifyApproval(request: SubsidyRequest): Promise<void> {
    await this.notificationsService.sendToUser({
      userId: request.requesterId,
      type: NotificationType.SUBSIDY_APPROVED,
      title: 'Solicitud de desembolso aprobada',
      body: `Su solicitud ${request.trackingCode ?? request.id} ha sido aprobada${request.autoApproved ? ' automaticamente' : ''}`,
      referenceId: request.id,
      referenceType: 'SubsidyRequest',
    });
  }

  private generateTrackingCode(): string {
    const now = new Date();
    const year = now.getFullYear();
    const seq = String(++this.trackingCodeCounter).padStart(6, '0');
    return `VBS-${year}${seq}`;
  }

  private formatCRC(amount: number): string {
    if (amount >= 1000) {
      return `\u20A1${Math.round(amount / 1000)}K`;
    }
    return `\u20A1${amount.toLocaleString('es-CR')}`;
  }
}
