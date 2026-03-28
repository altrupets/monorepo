import { Injectable, Logger, NotFoundException, BadRequestException } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository, LessThan } from 'typeorm';
import { SubsidyRequest, SubsidyRequestStatus } from './entities/subsidy-request.entity';
import { JurisdictionsService } from '../jurisdictions/jurisdictions.service';
import { Animal } from '../animals/entities/animal.entity';
import { NotificationsService } from '../notifications/notifications.service';
import { NotificationType } from '../notifications/enums/notification-type.enum';
import { UserRole } from '../auth/roles/user-role.enum';

@Injectable()
export class SubsidiesService {
  private readonly logger = new Logger(SubsidiesService.name);

  constructor(
    @InjectRepository(SubsidyRequest)
    private readonly subsidyRepository: Repository<SubsidyRequest>,
    @InjectRepository(Animal)
    private readonly animalRepository: Repository<Animal>,
    private readonly jurisdictionsService: JurisdictionsService,
    private readonly notificationsService: NotificationsService,
  ) {}

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

  async findOne(id: string): Promise<SubsidyRequest> {
    const request = await this.subsidyRepository.findOne({
      where: { id },
      relations: ['animal', 'requester', 'municipality'],
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
}
