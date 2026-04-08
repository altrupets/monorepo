import { Resolver, Query, Mutation, Args, ID } from '@nestjs/graphql';
import { UseGuards } from '@nestjs/common';
import { Campaign } from './entities/campaign.entity';
import { CampaignRegistration } from './entities/campaign-registration.entity';
import { CampaignsService } from './campaigns.service';
import { CampaignStatus } from './enums/campaign-status.enum';
import { JwtAuthGuard } from '../auth/jwt-auth.guard';
import { RolesGuard } from '../auth/roles/roles.guard';
import { Roles } from '../auth/roles/roles.decorator';
import { UserRole } from '../auth/roles/user-role.enum';
import { GqlUser } from '../auth/gql-user.decorator';
import { User } from '../users/entities/user.entity';
import { CreateCampaignInput } from './dto/create-campaign.input';
import { UpdateCampaignInput } from './dto/update-campaign.input';
import { RegisterForCampaignInput } from './dto/register-for-campaign.input';
import { CampaignMetrics } from './dto/campaign-metrics.output';

@Resolver(() => Campaign)
export class CampaignsResolver {
  constructor(private readonly campaignsService: CampaignsService) {}

  // ─── Mutations ──────────────────────────────────────────────────

  @Mutation(() => Campaign, {
    description: 'Create a new spay/neuter campaign (GOVERNMENT_ADMIN only)',
  })
  @UseGuards(JwtAuthGuard, RolesGuard)
  @Roles(UserRole.GOVERNMENT_ADMIN, UserRole.SUPER_USER)
  async createCampaign(
    @GqlUser() user: User,
    @Args('input') input: CreateCampaignInput,
  ): Promise<Campaign> {
    return this.campaignsService.createCampaign(user.id, input);
  }

  @Mutation(() => Campaign, {
    description: 'Update campaign details (GOVERNMENT_ADMIN only)',
  })
  @UseGuards(JwtAuthGuard, RolesGuard)
  @Roles(UserRole.GOVERNMENT_ADMIN, UserRole.SUPER_USER)
  async updateCampaign(
    @Args('input') input: UpdateCampaignInput,
  ): Promise<Campaign> {
    return this.campaignsService.updateCampaign(input);
  }

  @Mutation(() => Campaign, {
    description: 'Advance campaign to next status in the state machine (GOVERNMENT_ADMIN only)',
  })
  @UseGuards(JwtAuthGuard, RolesGuard)
  @Roles(UserRole.GOVERNMENT_ADMIN, UserRole.SUPER_USER)
  async advanceCampaignStatus(
    @Args('id', { type: () => ID }) id: string,
  ): Promise<Campaign> {
    return this.campaignsService.advanceCampaignStatus(id);
  }

  @Mutation(() => CampaignRegistration, {
    description: 'Register an animal for a campaign — public mutation, no auth required',
  })
  async registerForCampaign(
    @Args('input') input: RegisterForCampaignInput,
  ): Promise<CampaignRegistration> {
    return this.campaignsService.registerForCampaign(input);
  }

  @Mutation(() => CampaignRegistration, {
    description: 'Check in a registration on surgery day (GOVERNMENT_ADMIN only)',
  })
  @UseGuards(JwtAuthGuard, RolesGuard)
  @Roles(UserRole.GOVERNMENT_ADMIN, UserRole.SUPER_USER)
  async checkInRegistration(
    @Args('registrationId', { type: () => ID }) registrationId: string,
  ): Promise<CampaignRegistration> {
    return this.campaignsService.checkInRegistration(registrationId);
  }

  @Mutation(() => CampaignRegistration, {
    description: 'Record that a surgery was performed (GOVERNMENT_ADMIN only)',
  })
  @UseGuards(JwtAuthGuard, RolesGuard)
  @Roles(UserRole.GOVERNMENT_ADMIN, UserRole.SUPER_USER)
  async recordSurgery(
    @Args('registrationId', { type: () => ID }) registrationId: string,
    @Args('vetId', { type: () => ID }) vetId: string,
  ): Promise<CampaignRegistration> {
    return this.campaignsService.recordSurgery(registrationId, vetId);
  }

  // ─── Queries ────────────────────────────────────────────────────

  @Query(() => [Campaign], { name: 'campaigns' })
  @UseGuards(JwtAuthGuard, RolesGuard)
  @Roles(UserRole.GOVERNMENT_ADMIN, UserRole.SUPER_USER)
  async getCampaigns(
    @Args('municipalityId', { type: () => ID }) municipalityId: string,
    @Args('status', { type: () => CampaignStatus, nullable: true }) status?: CampaignStatus,
  ): Promise<Campaign[]> {
    return this.campaignsService.findAll(municipalityId, status);
  }

  @Query(() => Campaign, { name: 'campaign' })
  @UseGuards(JwtAuthGuard)
  async getCampaign(
    @Args('id', { type: () => ID }) id: string,
  ): Promise<Campaign> {
    return this.campaignsService.findOne(id);
  }

  @Query(() => CampaignMetrics, { name: 'campaignMetrics' })
  @UseGuards(JwtAuthGuard, RolesGuard)
  @Roles(UserRole.GOVERNMENT_ADMIN, UserRole.SUPER_USER)
  async getCampaignMetrics(
    @Args('municipalityId', { type: () => ID }) municipalityId: string,
  ): Promise<CampaignMetrics> {
    return this.campaignsService.getCampaignMetrics(municipalityId);
  }

  @Query(() => [CampaignRegistration], { name: 'campaignRegistrations' })
  @UseGuards(JwtAuthGuard)
  async getCampaignRegistrations(
    @Args('campaignId', { type: () => ID }) campaignId: string,
  ): Promise<CampaignRegistration[]> {
    return this.campaignsService.findRegistrations(campaignId);
  }
}
