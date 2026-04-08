import { Injectable, Logger, NotFoundException, BadRequestException } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository, In } from 'typeorm';
import { Campaign } from './entities/campaign.entity';
import { CampaignRegistration } from './entities/campaign-registration.entity';
import { CampaignStatus } from './enums/campaign-status.enum';
import { RegistrationStatus } from './enums/registration-status.enum';
import { CreateCampaignInput } from './dto/create-campaign.input';
import { UpdateCampaignInput } from './dto/update-campaign.input';
import { RegisterForCampaignInput } from './dto/register-for-campaign.input';
import { CampaignMetrics } from './dto/campaign-metrics.output';
import { getNextCampaignStatus } from './campaign-state-machine';

@Injectable()
export class CampaignsService {
  private readonly logger = new Logger(CampaignsService.name);
  private campaignCodeCounter = 0;

  constructor(
    @InjectRepository(Campaign)
    private readonly campaignRepository: Repository<Campaign>,
    @InjectRepository(CampaignRegistration)
    private readonly registrationRepository: Repository<CampaignRegistration>,
  ) {}

  // ─── Campaign CRUD ──────────────────────────────────────────────

  async createCampaign(
    createdById: string,
    input: CreateCampaignInput,
  ): Promise<Campaign> {
    const code = this.generateCampaignCode();

    const campaign = this.campaignRepository.create({
      municipalityId: input.municipalityId,
      title: input.title,
      code,
      status: CampaignStatus.DRAFT,
      location: input.location,
      maxCapacity: input.maxCapacity,
      surgeryDate: input.surgeryDate,
      promotionDate: input.promotionDate,
      registrationOpenDate: input.registrationOpenDate,
      registrationCloseDate: input.registrationCloseDate,
      orientationDate: input.orientationDate,
      budgetAllocated: input.budgetAllocated ?? 0,
      budgetSpent: 0,
      veterinarianIds: input.veterinarianIds,
      notes: input.notes,
      createdById,
    });

    const saved = await this.campaignRepository.save(campaign);
    this.logger.log(`Campaign ${code} created by user ${createdById}`);
    return this.findOne(saved.id);
  }

  async updateCampaign(input: UpdateCampaignInput): Promise<Campaign> {
    const campaign = await this.findOne(input.id);

    if (input.title !== undefined) campaign.title = input.title;
    if (input.location !== undefined) campaign.location = input.location;
    if (input.maxCapacity !== undefined) campaign.maxCapacity = input.maxCapacity;
    if (input.surgeryDate !== undefined) campaign.surgeryDate = input.surgeryDate;
    if (input.promotionDate !== undefined) campaign.promotionDate = input.promotionDate;
    if (input.registrationOpenDate !== undefined) campaign.registrationOpenDate = input.registrationOpenDate;
    if (input.registrationCloseDate !== undefined) campaign.registrationCloseDate = input.registrationCloseDate;
    if (input.orientationDate !== undefined) campaign.orientationDate = input.orientationDate;
    if (input.budgetAllocated !== undefined) campaign.budgetAllocated = input.budgetAllocated;
    if (input.budgetSpent !== undefined) campaign.budgetSpent = input.budgetSpent;
    if (input.veterinarianIds !== undefined) campaign.veterinarianIds = input.veterinarianIds;
    if (input.notes !== undefined) campaign.notes = input.notes;

    await this.campaignRepository.save(campaign);
    return this.findOne(campaign.id);
  }

  async advanceCampaignStatus(id: string): Promise<Campaign> {
    const campaign = await this.findOne(id);
    const nextStatus = getNextCampaignStatus(campaign.status);

    campaign.status = nextStatus;
    await this.campaignRepository.save(campaign);

    this.logger.log(`Campaign ${campaign.code} advanced to ${nextStatus}`);
    return this.findOne(campaign.id);
  }

  // ─── Queries ────────────────────────────────────────────────────

  async findOne(id: string): Promise<Campaign> {
    const campaign = await this.campaignRepository.findOne({
      where: { id },
      relations: ['municipality', 'createdBy', 'registrations'],
    });
    if (!campaign) {
      throw new NotFoundException(`Campaign with ID ${id} not found`);
    }
    return campaign;
  }

  async findAll(municipalityId: string, status?: CampaignStatus): Promise<Campaign[]> {
    const where: Record<string, any> = { municipalityId };
    if (status) {
      where.status = status;
    }

    return this.campaignRepository.find({
      where,
      relations: ['municipality', 'createdBy', 'registrations'],
      order: { createdAt: 'DESC' },
    });
  }

  async getCampaignMetrics(municipalityId: string): Promise<CampaignMetrics> {
    const campaigns = await this.campaignRepository.find({
      where: { municipalityId },
      relations: ['registrations'],
    });

    // Total sterilized = registrations with status OPERATED or beyond
    const operatedStatuses = [
      RegistrationStatus.OPERATED,
      RegistrationStatus.FOLLOW_UP_3D,
      RegistrationStatus.FOLLOW_UP_7D,
      RegistrationStatus.FOLLOW_UP_14D,
      RegistrationStatus.COMPLETED,
    ];

    let totalSterilized = 0;
    let totalBudgetSpent = 0;
    const communities = new Set<string>();
    const activeCampaignStatuses = [
      CampaignStatus.DRAFT,
      CampaignStatus.PUBLISHED,
      CampaignStatus.REGISTRATION_OPEN,
      CampaignStatus.REGISTRATION_CLOSED,
      CampaignStatus.IN_PROGRESS,
    ];
    let activeCampaigns = 0;
    let completedCampaigns = 0;
    let nearestSurgeryDays = Number.MAX_SAFE_INTEGER;
    const now = new Date();

    for (const campaign of campaigns) {
      communities.add(campaign.location);
      totalBudgetSpent += Number(campaign.budgetSpent) || 0;

      if (activeCampaignStatuses.includes(campaign.status)) {
        activeCampaigns++;
      }
      if (campaign.status === CampaignStatus.COMPLETED || campaign.status === CampaignStatus.ARCHIVED) {
        completedCampaigns++;
      }

      // Count sterilized animals
      if (campaign.registrations) {
        for (const reg of campaign.registrations) {
          if (operatedStatuses.includes(reg.status)) {
            totalSterilized++;
          }
        }
      }

      // Calculate days until next surgery
      if (campaign.surgeryDate && activeCampaignStatuses.includes(campaign.status)) {
        const surgeryDate = new Date(campaign.surgeryDate);
        const diffDays = Math.ceil(
          (surgeryDate.getTime() - now.getTime()) / (1000 * 60 * 60 * 24),
        );
        if (diffDays >= 0 && diffDays < nearestSurgeryDays) {
          nearestSurgeryDays = diffDays;
        }
      }
    }

    const avgCostPerAnimal = totalSterilized > 0
      ? totalBudgetSpent / totalSterilized
      : 0;

    return {
      totalSterilized,
      avgCostPerAnimal: Math.round(avgCostPerAnimal * 100) / 100,
      communitiesCovered: communities.size,
      communitiesTotal: 14, // Total communities in the municipality
      daysUntilNextCampaign: nearestSurgeryDays === Number.MAX_SAFE_INTEGER ? -1 : nearestSurgeryDays,
      totalCampaigns: campaigns.length,
      activeCampaigns,
      completedCampaigns,
    };
  }

  // ─── Registration management ────────────────────────────────────

  async registerForCampaign(input: RegisterForCampaignInput): Promise<CampaignRegistration> {
    const campaign = await this.findOne(input.campaignId);

    if (campaign.status !== CampaignStatus.REGISTRATION_OPEN) {
      throw new BadRequestException(
        `Campaign ${campaign.code} is not open for registration (current status: ${campaign.status})`,
      );
    }

    // Check capacity
    const currentCount = await this.registrationRepository.count({
      where: { campaignId: input.campaignId },
    });
    if (currentCount >= campaign.maxCapacity) {
      throw new BadRequestException(
        `Campaign ${campaign.code} has reached its maximum capacity of ${campaign.maxCapacity}`,
      );
    }

    const registration = this.registrationRepository.create({
      campaignId: input.campaignId,
      ownerName: input.ownerName,
      ownerPhone: input.ownerPhone,
      animalName: input.animalName,
      animalSpecies: input.animalSpecies,
      animalBreed: input.animalBreed,
      animalAge: input.animalAge,
      animalSex: input.animalSex,
      status: RegistrationStatus.REGISTERED,
      notes: input.notes,
    });

    const saved = await this.registrationRepository.save(registration);
    this.logger.log(`Registration ${saved.id} created for campaign ${campaign.code}`);
    return saved;
  }

  async findRegistrations(campaignId: string): Promise<CampaignRegistration[]> {
    return this.registrationRepository.find({
      where: { campaignId },
      relations: ['operatedBy'],
      order: { createdAt: 'ASC' },
    });
  }

  async checkInRegistration(registrationId: string): Promise<CampaignRegistration> {
    const registration = await this.registrationRepository.findOne({
      where: { id: registrationId },
    });
    if (!registration) {
      throw new NotFoundException(`Registration with ID ${registrationId} not found`);
    }

    if (registration.status !== RegistrationStatus.REGISTERED) {
      throw new BadRequestException(
        `Cannot check in registration with status ${registration.status}`,
      );
    }

    registration.status = RegistrationStatus.CHECKED_IN;
    return this.registrationRepository.save(registration);
  }

  async recordSurgery(registrationId: string, vetId: string): Promise<CampaignRegistration> {
    const registration = await this.registrationRepository.findOne({
      where: { id: registrationId },
    });
    if (!registration) {
      throw new NotFoundException(`Registration with ID ${registrationId} not found`);
    }

    if (registration.status !== RegistrationStatus.CHECKED_IN) {
      throw new BadRequestException(
        `Cannot record surgery for registration with status ${registration.status}`,
      );
    }

    registration.status = RegistrationStatus.OPERATED;
    registration.operatedById = vetId;
    registration.operatedAt = new Date();
    return this.registrationRepository.save(registration);
  }

  // ─── Private helpers ────────────────────────────────────────────

  private generateCampaignCode(): string {
    const now = new Date();
    const year = now.getFullYear();
    const seq = String(++this.campaignCodeCounter).padStart(3, '0');
    return `CAM-${year}-${seq}`;
  }
}
