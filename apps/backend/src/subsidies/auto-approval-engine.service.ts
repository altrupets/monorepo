import { Injectable, Logger } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository, Between } from 'typeorm';
import { SubsidyRequest, SubsidyRequestStatus } from './entities/subsidy-request.entity';
import { AutoApprovalRule } from './entities/auto-approval-rule.entity';
import { AutoApprovalRuleType } from './enums/auto-approval-rule-type.enum';
import { RuleEvaluationResult } from './dto/rule-evaluation-result.output';
import { User } from '../users/entities/user.entity';
import { Animal } from '../animals/entities/animal.entity';
import { VetProfile } from '../vet-profiles/entities/vet-profile.entity';

export interface EngineContext {
  request: SubsidyRequest;
  requester: User;
  animal: Animal;
  vetProfile?: VetProfile;
  municipalityId: string;
}

@Injectable()
export class AutoApprovalEngineService {
  private readonly logger = new Logger(AutoApprovalEngineService.name);

  constructor(
    @InjectRepository(AutoApprovalRule)
    private readonly ruleRepository: Repository<AutoApprovalRule>,
    @InjectRepository(SubsidyRequest)
    private readonly subsidyRepository: Repository<SubsidyRequest>,
  ) {}

  /**
   * Evaluate all enabled rules for a given subsidy request.
   * Never throws — wraps errors and defaults to manual review.
   */
  async evaluate(context: EngineContext): Promise<RuleEvaluationResult[]> {
    const results: RuleEvaluationResult[] = [];

    try {
      // Fetch enabled rules for this municipality
      const rules = await this.ruleRepository.find({
        where: { municipalityId: context.municipalityId, isEnabled: true },
        order: { ruleType: 'ASC' },
      });

      // If no rules configured, all checks pass by default (allow auto-approval)
      if (rules.length === 0) {
        return this.getDefaultPassResults();
      }

      for (const rule of rules) {
        const result = await this.evaluateRule(rule, context);
        results.push(result);
      }
    } catch (error) {
      this.logger.error('Auto-approval engine error, defaulting to manual review', error);
      return [
        {
          ruleType: AutoApprovalRuleType.VERIFIED_RESCUER,
          passed: false,
          reason: 'Engine evaluation error — sent to manual review',
          detail: error instanceof Error ? error.message : 'Unknown error',
        },
      ];
    }

    return results;
  }

  /**
   * Determines if all rule results pass — eligible for auto-approval.
   */
  allPassed(results: RuleEvaluationResult[]): boolean {
    return results.length > 0 && results.every((r) => r.passed);
  }

  private async evaluateRule(
    rule: AutoApprovalRule,
    context: EngineContext,
  ): Promise<RuleEvaluationResult> {
    try {
      switch (rule.ruleType) {
        case AutoApprovalRuleType.VERIFIED_RESCUER:
          return this.checkVerifiedRescuer(context);
        case AutoApprovalRuleType.REGISTERED_ANIMAL:
          return this.checkRegisteredAnimal(context);
        case AutoApprovalRuleType.WITHIN_BUDGET:
          return this.checkWithinBudget(context, rule);
        case AutoApprovalRuleType.AUTHORIZED_VET:
          return this.checkAuthorizedVet(context);
        case AutoApprovalRuleType.NO_DUPLICATE:
          return this.checkNoDuplicate(context, rule);
        default:
          return {
            ruleType: rule.ruleType,
            passed: false,
            reason: `Unknown rule type: ${rule.ruleType}`,
          };
      }
    } catch (error) {
      this.logger.warn(`Rule ${rule.ruleType} evaluation failed`, error);
      return {
        ruleType: rule.ruleType,
        passed: false,
        reason: 'Rule evaluation error',
        detail: error instanceof Error ? error.message : 'Unknown error',
      };
    }
  }

  private checkVerifiedRescuer(context: EngineContext): RuleEvaluationResult {
    const passed = context.requester.isVerified === true;
    return {
      ruleType: AutoApprovalRuleType.VERIFIED_RESCUER,
      passed,
      reason: passed
        ? 'Rescatista verificada'
        : 'Rescatista no verificada',
      detail: `${context.requester.firstName ?? ''} ${context.requester.lastName ?? ''}`.trim() || context.requester.username,
    };
  }

  private checkRegisteredAnimal(context: EngineContext): RuleEvaluationResult {
    const hasMicrochip = !!context.animal.microchipId;
    const hasCasaCuna = !!context.animal.casaCunaId;
    const passed = hasMicrochip || hasCasaCuna;
    return {
      ruleType: AutoApprovalRuleType.REGISTERED_ANIMAL,
      passed,
      reason: passed
        ? 'Animal registrado'
        : 'Animal sin microchip ni casa cuna',
      detail: `${context.animal.name} · ${context.animal.species}${hasMicrochip ? ` · Microchip: ${context.animal.microchipId}` : ''}${hasCasaCuna ? ` · Casa Cuna` : ''}`,
    };
  }

  private async checkWithinBudget(
    context: EngineContext,
    rule: AutoApprovalRule,
  ): Promise<RuleEvaluationResult> {
    const monthlyBudget = rule.parameters?.monthlyBudget ?? 500000; // Default 500K CRC

    // Calculate how much has been approved this month
    const now = new Date();
    const monthStart = new Date(now.getFullYear(), now.getMonth(), 1);
    const monthEnd = new Date(now.getFullYear(), now.getMonth() + 1, 0, 23, 59, 59, 999);

    const result = await this.subsidyRepository
      .createQueryBuilder('sr')
      .select('COALESCE(SUM(sr.amountRequested), 0)', 'total')
      .where('sr.municipalityId = :municipalityId', { municipalityId: context.municipalityId })
      .andWhere('sr.status IN (:...statuses)', {
        statuses: [SubsidyRequestStatus.APPROVED, SubsidyRequestStatus.PAID],
      })
      .andWhere('sr.createdAt BETWEEN :start AND :end', {
        start: monthStart,
        end: monthEnd,
      })
      .getRawOne();

    const disbursed = parseFloat(result?.total ?? '0');
    const available = monthlyBudget - disbursed;
    const passed = context.request.amountRequested <= available;

    return {
      ruleType: AutoApprovalRuleType.WITHIN_BUDGET,
      passed,
      reason: passed
        ? 'Dentro de presupuesto'
        : 'Excede presupuesto disponible',
      detail: `${this.formatCRC(context.request.amountRequested)} solicitados · ${this.formatCRC(available)} disponibles de ${this.formatCRC(monthlyBudget)} mensuales`,
    };
  }

  private checkAuthorizedVet(context: EngineContext): RuleEvaluationResult {
    if (!context.vetProfile) {
      return {
        ruleType: AutoApprovalRuleType.AUTHORIZED_VET,
        passed: false,
        reason: 'Sin veterinaria asignada',
      };
    }

    const passed = context.vetProfile.isVerified === true;
    return {
      ruleType: AutoApprovalRuleType.AUTHORIZED_VET,
      passed,
      reason: passed
        ? 'Veterinaria autorizada'
        : 'Veterinaria no verificada',
      detail: `${context.vetProfile.clinicName}${context.vetProfile.district ? ` · ${context.vetProfile.district}` : ''}`,
    };
  }

  private async checkNoDuplicate(
    context: EngineContext,
    rule: AutoApprovalRule,
  ): Promise<RuleEvaluationResult> {
    const windowDays = rule.parameters?.windowDays ?? 30; // Default 30 days
    const windowStart = new Date();
    windowStart.setDate(windowStart.getDate() - windowDays);

    const existing = await this.subsidyRepository.findOne({
      where: {
        animalId: context.animal.id,
        requesterId: context.requester.id,
        createdAt: Between(windowStart, new Date()) as any,
      },
      order: { createdAt: 'DESC' },
    });

    // Exclude the current request from the duplicate check
    const isDuplicate = existing && existing.id !== context.request.id;

    return {
      ruleType: AutoApprovalRuleType.NO_DUPLICATE,
      passed: !isDuplicate,
      reason: !isDuplicate
        ? 'Sin solicitudes duplicadas'
        : 'Solicitud duplicada encontrada',
      detail: isDuplicate
        ? `Solicitud previa: ${existing.trackingCode ?? existing.id} el ${existing.createdAt.toLocaleDateString('es-CR')}`
        : `Ventana de ${windowDays} dias sin duplicados`,
    };
  }

  private getDefaultPassResults(): RuleEvaluationResult[] {
    return Object.values(AutoApprovalRuleType).map((ruleType) => ({
      ruleType,
      passed: true,
      reason: 'Regla no configurada — aprobada por defecto',
    }));
  }

  private formatCRC(amount: number): string {
    if (amount >= 1000) {
      return `\u20A1${Math.round(amount / 1000)}K`;
    }
    return `\u20A1${amount.toLocaleString('es-CR')}`;
  }
}
