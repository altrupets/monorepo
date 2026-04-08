import { Resolver, Query, Mutation, Args, ID, Float } from '@nestjs/graphql';
import { UseGuards } from '@nestjs/common';
import { SubsidyRequest, SubsidyRequestStatus } from './entities/subsidy-request.entity';
import { AutoApprovalRule } from './entities/auto-approval-rule.entity';
import { ApprovalAuditLog } from './entities/approval-audit-log.entity';
import { SubsidiesService } from './subsidies.service';
import { JwtAuthGuard } from '../auth/jwt-auth.guard';
import { RolesGuard } from '../auth/roles/roles.guard';
import { Roles } from '../auth/roles/roles.decorator';
import { UserRole } from '../auth/roles/user-role.enum';
import { GqlUser } from '../auth/gql-user.decorator';
import { User } from '../users/entities/user.entity';
import { CreateVetSubsidyRequestInput } from './dto/create-vet-subsidy-request.input';
import { ApproveSubsidyRequestInput } from './dto/approve-subsidy-request.input';
import { RejectSubsidyRequestInput } from './dto/reject-subsidy-request.input';
import { UpsertAutoApprovalRuleInput } from './dto/upsert-auto-approval-rule.input';
import { SubsidyFiltersInput } from './dto/subsidy-filters.input';
import { BudgetStatus } from './dto/budget-status.output';

@Resolver(() => SubsidyRequest)
export class SubsidiesResolver {
  constructor(private readonly subsidiesService: SubsidiesService) {}

  // ─── Legacy mutations (kept for backward compatibility) ─────────

  @Mutation(() => SubsidyRequest)
  @UseGuards(JwtAuthGuard)
  async createSubsidyRequest(
    @GqlUser() user: User,
    @Args('animalId', { type: () => ID }) animalId: string,
    @Args('amountRequested', { type: () => Float }) amountRequested: number,
    @Args('justification') justification: string,
  ): Promise<SubsidyRequest> {
    return this.subsidiesService.create({
      animalId,
      amountRequested,
      justification,
      requesterId: user.id,
    });
  }

  @Query(() => SubsidyRequest, { name: 'subsidyRequest' })
  @UseGuards(JwtAuthGuard)
  async getSubsidyRequest(
    @Args('id', { type: () => ID }) id: string,
  ): Promise<SubsidyRequest> {
    return this.subsidiesService.findOne(id);
  }

  @Query(() => [SubsidyRequest], { name: 'mySubsidyRequests' })
  @UseGuards(JwtAuthGuard)
  async getMySubsidyRequests(
    @GqlUser() user: User,
  ): Promise<SubsidyRequest[]> {
    return this.subsidiesService.findAllByRequester(user.id);
  }

  @Mutation(() => SubsidyRequest)
  @UseGuards(JwtAuthGuard)
  async updateSubsidyStatus(
    @Args('id', { type: () => ID }) id: string,
    @Args('status', { type: () => SubsidyRequestStatus }) status: SubsidyRequestStatus,
  ): Promise<SubsidyRequest> {
    return this.subsidiesService.updateStatus(id, status);
  }

  // ─── ALT-64: New mutations ──────────────────────────────────────

  @Mutation(() => SubsidyRequest, {
    description: 'Create a vet subsidy request with auto-approval engine evaluation',
  })
  @UseGuards(JwtAuthGuard)
  async createVetSubsidyRequest(
    @GqlUser() user: User,
    @Args('input') input: CreateVetSubsidyRequestInput,
  ): Promise<SubsidyRequest> {
    return this.subsidiesService.createVetSubsidyRequest(user.id, input);
  }

  @Mutation(() => SubsidyRequest, {
    description: 'Manually approve a subsidy request (GOVERNMENT_ADMIN only)',
  })
  @UseGuards(JwtAuthGuard, RolesGuard)
  @Roles(UserRole.GOVERNMENT_ADMIN, UserRole.SUPER_USER)
  async approveSubsidyRequest(
    @GqlUser() user: User,
    @Args('input') input: ApproveSubsidyRequestInput,
  ): Promise<SubsidyRequest> {
    return this.subsidiesService.approveSubsidyRequest(input.id, user.id, input.notes);
  }

  @Mutation(() => SubsidyRequest, {
    description: 'Reject a subsidy request with reason (GOVERNMENT_ADMIN only)',
  })
  @UseGuards(JwtAuthGuard, RolesGuard)
  @Roles(UserRole.GOVERNMENT_ADMIN, UserRole.SUPER_USER)
  async rejectSubsidyRequest(
    @GqlUser() user: User,
    @Args('input') input: RejectSubsidyRequestInput,
  ): Promise<SubsidyRequest> {
    return this.subsidiesService.rejectSubsidyRequest(
      input.id,
      user.id,
      input.rejectionReason,
      input.notes,
    );
  }

  @Mutation(() => AutoApprovalRule, {
    description: 'Create or update an auto-approval rule (GOVERNMENT_ADMIN only)',
  })
  @UseGuards(JwtAuthGuard, RolesGuard)
  @Roles(UserRole.GOVERNMENT_ADMIN, UserRole.SUPER_USER)
  async upsertAutoApprovalRule(
    @Args('input') input: UpsertAutoApprovalRuleInput,
  ): Promise<AutoApprovalRule> {
    return this.subsidiesService.upsertAutoApprovalRule(input);
  }

  @Mutation(() => AutoApprovalRule, {
    description: 'Toggle an auto-approval rule on/off (GOVERNMENT_ADMIN only)',
  })
  @UseGuards(JwtAuthGuard, RolesGuard)
  @Roles(UserRole.GOVERNMENT_ADMIN, UserRole.SUPER_USER)
  async toggleApprovalRule(
    @Args('id', { type: () => ID }) id: string,
    @Args('isEnabled') isEnabled: boolean,
  ): Promise<AutoApprovalRule> {
    return this.subsidiesService.toggleApprovalRule(id, isEnabled);
  }

  // ─── ALT-64: New queries ────────────────────────────────────────

  @Query(() => [SubsidyRequest], { name: 'pendingSubsidyRequests' })
  @UseGuards(JwtAuthGuard, RolesGuard)
  @Roles(UserRole.GOVERNMENT_ADMIN, UserRole.SUPER_USER)
  async getPendingSubsidyRequests(
    @Args('filters', { nullable: true }) filters?: SubsidyFiltersInput,
  ): Promise<SubsidyRequest[]> {
    return this.subsidiesService.findPending(filters);
  }

  @Query(() => [SubsidyRequest], { name: 'approvedSubsidyRequests' })
  @UseGuards(JwtAuthGuard, RolesGuard)
  @Roles(UserRole.GOVERNMENT_ADMIN, UserRole.SUPER_USER)
  async getApprovedSubsidyRequests(
    @Args('filters', { nullable: true }) filters?: SubsidyFiltersInput,
  ): Promise<SubsidyRequest[]> {
    return this.subsidiesService.findApproved(filters);
  }

  @Query(() => BudgetStatus, { name: 'subsidyBudgetStatus' })
  @UseGuards(JwtAuthGuard, RolesGuard)
  @Roles(UserRole.GOVERNMENT_ADMIN, UserRole.SUPER_USER)
  async getSubsidyBudgetStatus(
    @Args('municipalityId', { type: () => ID }) municipalityId: string,
  ): Promise<BudgetStatus> {
    return this.subsidiesService.getBudgetStatus(municipalityId);
  }

  @Query(() => [ApprovalAuditLog], { name: 'subsidyAuditLog' })
  @UseGuards(JwtAuthGuard)
  async getSubsidyAuditLog(
    @Args('subsidyRequestId', { type: () => ID }) subsidyRequestId: string,
  ): Promise<ApprovalAuditLog[]> {
    return this.subsidiesService.getAuditLog(subsidyRequestId);
  }

  @Query(() => [AutoApprovalRule], { name: 'approvalRules' })
  @UseGuards(JwtAuthGuard, RolesGuard)
  @Roles(UserRole.GOVERNMENT_ADMIN, UserRole.SUPER_USER)
  async getApprovalRules(
    @Args('municipalityId', { type: () => ID }) municipalityId: string,
  ): Promise<AutoApprovalRule[]> {
    return this.subsidiesService.getApprovalRules(municipalityId);
  }
}
