import {
  Injectable,
  NotFoundException,
  BadRequestException,
} from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository, Not, In } from 'typeorm';
import { AdoptionApplication } from './entities/adoption-application.entity';
import { AdoptionListing } from './entities/adoption-listing.entity';
import { ApplicationStatus } from './enums/application-status.enum';
import { ListingStatus } from './enums/listing-status.enum';
import { NotificationsService } from '../notifications/notifications.service';
import { NotificationType } from '../notifications/enums/notification-type.enum';
import { SubmitAdoptionApplicationInput } from './dto/submit-adoption-application.input';

const ALLOWED_TRANSITIONS: Record<ApplicationStatus, ApplicationStatus[]> = {
  [ApplicationStatus.SUBMITTED]: [
    ApplicationStatus.IN_REVIEW,
    ApplicationStatus.REJECTED,
  ],
  [ApplicationStatus.IN_REVIEW]: [
    ApplicationStatus.VISIT_SCHEDULED,
    ApplicationStatus.REJECTED,
  ],
  [ApplicationStatus.VISIT_SCHEDULED]: [
    ApplicationStatus.VISIT_COMPLETED,
    ApplicationStatus.REJECTED,
  ],
  [ApplicationStatus.VISIT_COMPLETED]: [
    ApplicationStatus.APPROVED,
    ApplicationStatus.REJECTED,
  ],
  [ApplicationStatus.APPROVED]: [],
  [ApplicationStatus.REJECTED]: [],
};

@Injectable()
export class AdoptionApplicationsService {
  constructor(
    @InjectRepository(AdoptionApplication)
    private readonly applicationRepository: Repository<AdoptionApplication>,
    @InjectRepository(AdoptionListing)
    private readonly listingRepository: Repository<AdoptionListing>,
    private readonly notificationsService: NotificationsService,
  ) {}

  async submit(
    input: SubmitAdoptionApplicationInput,
    applicantUserId: string,
  ): Promise<AdoptionApplication> {
    // Validate listing exists and is ACTIVE
    const listing = await this.listingRepository.findOne({
      where: { id: input.listingId },
    });
    if (!listing) {
      throw new NotFoundException(
        `Adoption listing with ID ${input.listingId} not found`,
      );
    }
    if (listing.status !== ListingStatus.ACTIVE) {
      throw new BadRequestException(
        'Can only submit applications for active listings',
      );
    }

    // Check max 1 application per applicant per listing
    const existingForListing = await this.applicationRepository.findOne({
      where: { listingId: input.listingId, applicantUserId },
    });
    if (existingForListing) {
      throw new BadRequestException(
        'You already have an application for this listing',
      );
    }

    // Check max 3 active applications globally
    const activeCount = await this.applicationRepository.count({
      where: {
        applicantUserId,
        status: Not(In([ApplicationStatus.REJECTED, ApplicationStatus.APPROVED])),
      },
    });
    if (activeCount >= 3) {
      throw new BadRequestException(
        'You already have 3 active applications. Please wait for existing applications to be resolved.',
      );
    }

    const application = this.applicationRepository.create({
      ...input,
      applicantUserId,
      status: ApplicationStatus.SUBMITTED,
    });

    const saved = await this.applicationRepository.save(application);

    // Send push notification to publisher
    this.notificationsService
      .sendToUser({
        userId: listing.publisherId,
        type: NotificationType.ADOPTION_APPLICATION_SUBMITTED,
        title: 'Nueva solicitud de adopcion',
        body: `Se ha recibido una nueva solicitud para tu listado "${listing.title}"`,
        referenceId: saved.id,
        referenceType: 'AdoptionApplication',
      })
      .catch(() => {
        // Notification failures should not block the main flow
      });

    return saved;
  }

  async review(
    applicationId: string,
    reviewerUserId: string,
  ): Promise<AdoptionApplication> {
    const application = await this.findApplicationById(applicationId);
    this.validateTransition(application.status, ApplicationStatus.IN_REVIEW);

    application.status = ApplicationStatus.IN_REVIEW;
    application.reviewerUserId = reviewerUserId;

    return this.applicationRepository.save(application);
  }

  async scheduleVisit(
    applicationId: string,
    reviewerUserId: string,
    scheduledDate: Date,
  ): Promise<AdoptionApplication> {
    const application = await this.findApplicationById(applicationId);
    this.validateTransition(
      application.status,
      ApplicationStatus.VISIT_SCHEDULED,
    );

    application.status = ApplicationStatus.VISIT_SCHEDULED;
    application.reviewerUserId = reviewerUserId;
    application.visitScheduledAt = scheduledDate;

    const saved = await this.applicationRepository.save(application);

    // Send push notification to applicant
    this.notificationsService
      .sendToUser({
        userId: application.applicantUserId,
        type: NotificationType.ADOPTION_VISIT_SCHEDULED,
        title: 'Visita programada',
        body: `Se ha programado una visita para tu solicitud de adopcion para el ${scheduledDate.toLocaleDateString()}`,
        referenceId: saved.id,
        referenceType: 'AdoptionApplication',
      })
      .catch(() => {
        // Notification failures should not block the main flow
      });

    return saved;
  }

  async completeVisit(
    applicationId: string,
    reviewerUserId: string,
    notes: string,
  ): Promise<AdoptionApplication> {
    const application = await this.findApplicationById(applicationId);
    this.validateTransition(
      application.status,
      ApplicationStatus.VISIT_COMPLETED,
    );

    application.status = ApplicationStatus.VISIT_COMPLETED;
    application.reviewerUserId = reviewerUserId;
    application.visitCompletedAt = new Date();
    application.visitNotes = notes;

    return this.applicationRepository.save(application);
  }

  async approve(
    applicationId: string,
    reviewerUserId: string,
  ): Promise<AdoptionApplication> {
    const application = await this.findApplicationById(applicationId);
    this.validateTransition(application.status, ApplicationStatus.APPROVED);

    application.status = ApplicationStatus.APPROVED;
    application.reviewerUserId = reviewerUserId;

    const saved = await this.applicationRepository.save(application);

    // Close listing as ADOPTED
    const listing = await this.listingRepository.findOne({
      where: { id: application.listingId },
    });
    if (listing) {
      listing.status = ListingStatus.ADOPTED;
      listing.closedAt = new Date();
      await this.listingRepository.save(listing);
    }

    // Reject all other pending applications for this listing
    const otherApplications = await this.applicationRepository.find({
      where: {
        listingId: application.listingId,
        status: Not(In([ApplicationStatus.APPROVED, ApplicationStatus.REJECTED])),
      },
    });

    for (const other of otherApplications) {
      if (other.id !== applicationId) {
        other.status = ApplicationStatus.REJECTED;
        other.rejectionReason =
          'Another applicant has been approved for this listing';
        await this.applicationRepository.save(other);

        // Notify rejected applicants
        this.notificationsService
          .sendToUser({
            userId: other.applicantUserId,
            type: NotificationType.ADOPTION_REJECTED,
            title: 'Solicitud de adopcion no aprobada',
            body: 'El animal ya fue adoptado por otro solicitante',
            referenceId: other.id,
            referenceType: 'AdoptionApplication',
          })
          .catch(() => {
            // Notification failures should not block the main flow
          });
      }
    }

    // Notify the approved applicant
    this.notificationsService
      .sendToUser({
        userId: application.applicantUserId,
        type: NotificationType.ADOPTION_APPROVED,
        title: 'Solicitud de adopcion aprobada',
        body: 'Tu solicitud de adopcion ha sido aprobada. Felicidades!',
        referenceId: saved.id,
        referenceType: 'AdoptionApplication',
      })
      .catch(() => {
        // Notification failures should not block the main flow
      });

    return saved;
  }

  async reject(
    applicationId: string,
    reviewerUserId: string,
    reason: string,
  ): Promise<AdoptionApplication> {
    const application = await this.findApplicationById(applicationId);
    this.validateTransition(application.status, ApplicationStatus.REJECTED);

    application.status = ApplicationStatus.REJECTED;
    application.reviewerUserId = reviewerUserId;
    application.rejectionReason = reason;

    const saved = await this.applicationRepository.save(application);

    // Notify the rejected applicant
    this.notificationsService
      .sendToUser({
        userId: application.applicantUserId,
        type: NotificationType.ADOPTION_REJECTED,
        title: 'Solicitud de adopcion rechazada',
        body: `Tu solicitud de adopcion ha sido rechazada. Razon: ${reason}`,
        referenceId: saved.id,
        referenceType: 'AdoptionApplication',
      })
      .catch(() => {
        // Notification failures should not block the main flow
      });

    return saved;
  }

  async findByListing(
    listingId: string,
    status?: ApplicationStatus,
  ): Promise<AdoptionApplication[]> {
    const where: Record<string, unknown> = { listingId };
    if (status) {
      where.status = status;
    }

    return this.applicationRepository.find({
      where,
      relations: ['applicant'],
      order: { createdAt: 'DESC' },
    });
  }

  async findMyApplications(
    applicantUserId: string,
  ): Promise<AdoptionApplication[]> {
    return this.applicationRepository.find({
      where: { applicantUserId },
      relations: ['listing', 'listing.animal'],
      order: { createdAt: 'DESC' },
    });
  }

  private async findApplicationById(
    applicationId: string,
  ): Promise<AdoptionApplication> {
    const application = await this.applicationRepository.findOne({
      where: { id: applicationId },
    });
    if (!application) {
      throw new NotFoundException(
        `Adoption application with ID ${applicationId} not found`,
      );
    }
    return application;
  }

  private validateTransition(
    current: ApplicationStatus,
    target: ApplicationStatus,
  ): void {
    const allowed = ALLOWED_TRANSITIONS[current];
    if (!allowed || !allowed.includes(target)) {
      throw new BadRequestException(
        `Cannot transition from ${current} to ${target}`,
      );
    }
  }
}
