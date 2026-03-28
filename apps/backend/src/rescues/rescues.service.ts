import {
  Injectable,
  Logger,
  NotFoundException,
  BadRequestException,
  ForbiddenException,
} from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository, EntityManager } from 'typeorm';
import { nanoid } from 'nanoid';
import { RescueAlert } from './entities/rescue-alert.entity';
import { RescueStatus } from './enums/rescue-status.enum';
import { RescueStateMachine } from './rescue-state-machine';
import { RescueMatchingService } from './rescue-matching.service';
import { NotificationsService } from '../notifications/notifications.service';
import { NotificationType } from '../notifications/enums/notification-type.enum';
import { CreateRescueAlertInput } from './dto/create-rescue-alert.input';
import { UpdateRescueProgressInput } from './dto/update-rescue-progress.input';
import { CompleteRescueInput } from './dto/complete-rescue.input';

@Injectable()
export class RescuesService {
  private readonly logger = new Logger(RescuesService.name);

  constructor(
    @InjectRepository(RescueAlert)
    private readonly rescueAlertRepository: Repository<RescueAlert>,
    private readonly stateMachine: RescueStateMachine,
    private readonly matchingService: RescueMatchingService,
    private readonly notificationsService: NotificationsService,
    private readonly entityManager: EntityManager,
  ) {}

  async createAlert(
    input: CreateRescueAlertInput,
    userId: string,
  ): Promise<RescueAlert> {
    const trackingCode = `RSC-${nanoid(6).toUpperCase()}`;
    const expiresAt = new Date(Date.now() + 15 * 60 * 1000);

    const alert = this.rescueAlertRepository.create({
      reportedById: userId,
      location: {
        type: 'Point',
        coordinates: [input.longitude, input.latitude],
      },
      locationDescription: input.locationDescription,
      urgency: input.urgency,
      description: input.description,
      imageUrls: input.imageBase64s,
      animalType: input.animalType,
      status: RescueStatus.CREATED,
      trackingCode,
      expiresAt,
    });

    const saved = await this.rescueAlertRepository.save(alert);

    // Find nearby auxiliares and assign
    const nearbyAuxiliares = await this.matchingService.findNearbyAuxiliares(
      input.longitude,
      input.latitude,
      saved.searchRadiusMeters,
    );

    if (nearbyAuxiliares.length > 0) {
      this.stateMachine.transition(saved, RescueStatus.ASSIGNED, userId);
      await this.rescueAlertRepository.save(saved);

      const userIds = nearbyAuxiliares.map((a) => a.userId);
      this.notificationsService
        .sendToUsers({
          userIds,
          type: NotificationType.RESCUE_ALERT,
          title: 'New Rescue Alert',
          body: `A ${input.animalType ?? 'animal'} needs help nearby! Tracking: ${trackingCode}`,
          referenceId: saved.id,
          referenceType: 'RescueAlert',
        })
        .catch((error) => {
          this.logger.error(
            'Failed to send rescue alert notifications',
            error instanceof Error ? error.message : String(error),
          );
        });
    }

    return saved;
  }

  async acceptAlert(
    alertId: string,
    auxiliarId: string,
  ): Promise<RescueAlert> {
    const alert = await this.findAlertOrFail(alertId);

    if (alert.status !== RescueStatus.ASSIGNED) {
      throw new BadRequestException(
        'Alert must be in ASSIGNED status to accept',
      );
    }

    this.stateMachine.transition(alert, RescueStatus.ACCEPTED, auxiliarId);
    const saved = await this.rescueAlertRepository.save(alert);

    this.notificationsService
      .sendToUser({
        userId: alert.reportedById,
        type: NotificationType.RESCUE_ACCEPTED,
        title: 'Rescue Accepted',
        body: `Your rescue alert ${alert.trackingCode} has been accepted by a helper`,
        referenceId: saved.id,
        referenceType: 'RescueAlert',
      })
      .catch((error) => {
        this.logger.error(
          'Failed to send rescue accepted notification',
          error instanceof Error ? error.message : String(error),
        );
      });

    return saved;
  }

  async rejectAlert(
    alertId: string,
    auxiliarId: string,
    reason?: string,
  ): Promise<RescueAlert> {
    const alert = await this.findAlertOrFail(alertId);

    this.stateMachine.transition(alert, RescueStatus.REJECTED, auxiliarId);
    const saved = await this.rescueAlertRepository.save(alert);

    this.logger.log(
      `Alert ${alertId} rejected by ${auxiliarId}${reason ? `: ${reason}` : ''}`,
    );

    // Re-search for other auxiliares
    if (alert.location) {
      const coords = alert.location.coordinates ?? [0, 0];
      const nearbyAuxiliares = await this.matchingService.findNearbyAuxiliares(
        coords[0],
        coords[1],
        alert.searchRadiusMeters,
      );

      if (nearbyAuxiliares.length > 0) {
        // Reset to ASSIGNED so another auxiliar can pick it up
        saved.status = RescueStatus.CREATED;
        this.stateMachine.transition(saved, RescueStatus.ASSIGNED, auxiliarId);
        saved.auxiliarId = null as any;
        await this.rescueAlertRepository.save(saved);

        const userIds = nearbyAuxiliares
          .filter((a) => a.userId !== auxiliarId)
          .map((a) => a.userId);

        if (userIds.length > 0) {
          this.notificationsService
            .sendToUsers({
              userIds,
              type: NotificationType.RESCUE_ALERT,
              title: 'Rescue Alert Available',
              body: `A rescue alert ${alert.trackingCode} needs a helper`,
              referenceId: saved.id,
              referenceType: 'RescueAlert',
            })
            .catch(() => {});
        }
      }
    }

    return saved;
  }

  async updateProgress(
    input: UpdateRescueProgressInput,
    auxiliarId: string,
  ): Promise<RescueAlert> {
    const alert = await this.findAlertOrFail(input.alertId);

    if (alert.auxiliarId !== auxiliarId) {
      throw new ForbiddenException(
        'Only the assigned auxiliar can update progress',
      );
    }

    if (alert.status === RescueStatus.ACCEPTED) {
      this.stateMachine.transition(alert, RescueStatus.IN_PROGRESS, auxiliarId);
    } else if (alert.status !== RescueStatus.IN_PROGRESS) {
      throw new BadRequestException(
        'Alert must be ACCEPTED or IN_PROGRESS to update progress',
      );
    }

    alert.conditionAssessment = input.conditionAssessment;
    if (input.imageBase64s) {
      alert.auxiliarPhotoUrls = [
        ...(alert.auxiliarPhotoUrls ?? []),
        ...input.imageBase64s,
      ];
    }

    return this.rescueAlertRepository.save(alert);
  }

  async requestTransfer(
    alertId: string,
    auxiliarId: string,
  ): Promise<RescueAlert> {
    const alert = await this.findAlertOrFail(alertId);

    if (alert.auxiliarId !== auxiliarId) {
      throw new ForbiddenException(
        'Only the assigned auxiliar can request a transfer',
      );
    }

    if (
      alert.status !== RescueStatus.IN_PROGRESS &&
      alert.status !== RescueStatus.ACCEPTED
    ) {
      throw new BadRequestException(
        'Alert must be ACCEPTED or IN_PROGRESS to request transfer',
      );
    }

    // Find available rescuers
    if (alert.location) {
      const coords = alert.location.coordinates ?? [0, 0];
      const rescuers = await this.matchingService.findAvailableRescuers(
        coords[0],
        coords[1],
        alert.searchRadiusMeters,
      );

      if (rescuers.length > 0) {
        const userIds = rescuers.map((r) => r.userId);
        this.notificationsService
          .sendToUsers({
            userIds,
            type: NotificationType.RESCUE_ALERT,
            title: 'Rescue Transfer Request',
            body: `A helper needs a rescuer for alert ${alert.trackingCode}`,
            referenceId: alert.id,
            referenceType: 'RescueAlert',
          })
          .catch((error) => {
            this.logger.error(
              'Failed to send transfer request notifications',
              error instanceof Error ? error.message : String(error),
            );
          });
      }
    }

    return alert;
  }

  async acceptTransfer(
    alertId: string,
    rescuerId: string,
  ): Promise<RescueAlert> {
    const alert = await this.findAlertOrFail(alertId);

    if (
      alert.status !== RescueStatus.IN_PROGRESS &&
      alert.status !== RescueStatus.ACCEPTED
    ) {
      throw new BadRequestException(
        'Alert must be ACCEPTED or IN_PROGRESS to accept transfer',
      );
    }

    // Ensure we transition through IN_PROGRESS if needed
    if (alert.status === RescueStatus.ACCEPTED) {
      this.stateMachine.transition(alert, RescueStatus.IN_PROGRESS, alert.auxiliarId ?? rescuerId);
    }

    alert.rescuerId = rescuerId;
    this.stateMachine.transition(alert, RescueStatus.TRANSFERRED, rescuerId);
    const saved = await this.rescueAlertRepository.save(alert);

    // Notify creator and auxiliar
    const notifyUserIds = [alert.reportedById];
    if (alert.auxiliarId) {
      notifyUserIds.push(alert.auxiliarId);
    }

    this.notificationsService
      .sendToUsers({
        userIds: notifyUserIds,
        type: NotificationType.RESCUE_TRANSFERRED,
        title: 'Rescue Transferred',
        body: `Alert ${alert.trackingCode} has been transferred to a rescuer`,
        referenceId: saved.id,
        referenceType: 'RescueAlert',
      })
      .catch((error) => {
        this.logger.error(
          'Failed to send transfer notifications',
          error instanceof Error ? error.message : String(error),
        );
      });

    return saved;
  }

  async completeRescue(
    input: CompleteRescueInput,
    rescuerId: string,
  ): Promise<RescueAlert> {
    const alert = await this.findAlertOrFail(input.alertId);

    if (alert.rescuerId !== rescuerId) {
      throw new ForbiddenException(
        'Only the assigned rescuer can complete the rescue',
      );
    }

    this.stateMachine.transition(alert, RescueStatus.COMPLETED, rescuerId);
    const saved = await this.rescueAlertRepository.save(alert);

    // Notify all participants
    const notifyUserIds = [alert.reportedById];
    if (alert.auxiliarId) {
      notifyUserIds.push(alert.auxiliarId);
    }
    if (alert.rescuerId && alert.rescuerId !== rescuerId) {
      notifyUserIds.push(alert.rescuerId);
    }

    this.notificationsService
      .sendToUsers({
        userIds: notifyUserIds,
        type: NotificationType.RESCUE_TRANSFERRED,
        title: 'Rescue Completed',
        body: `Rescue ${alert.trackingCode} has been completed successfully`,
        referenceId: saved.id,
        referenceType: 'RescueAlert',
      })
      .catch((error) => {
        this.logger.error(
          'Failed to send completion notifications',
          error instanceof Error ? error.message : String(error),
        );
      });

    return saved;
  }

  async cancelAlert(
    alertId: string,
    userId: string,
    reason?: string,
  ): Promise<RescueAlert> {
    const alert = await this.findAlertOrFail(alertId);

    if (alert.reportedById !== userId) {
      throw new ForbiddenException(
        'Only the creator can cancel this rescue alert',
      );
    }

    this.stateMachine.transition(alert, RescueStatus.CANCELLED, userId);
    const saved = await this.rescueAlertRepository.save(alert);

    this.logger.log(
      `Alert ${alertId} cancelled by ${userId}${reason ? `: ${reason}` : ''}`,
    );

    return saved;
  }

  async escalateSearch(alertId: string): Promise<RescueAlert> {
    const alert = await this.findAlertOrFail(alertId);

    alert.searchRadiusMeters = 25000;
    await this.rescueAlertRepository.save(alert);

    // Re-search with expanded radius
    if (alert.location) {
      const coords = alert.location.coordinates ?? [0, 0];
      const nearbyAuxiliares = await this.matchingService.findNearbyAuxiliares(
        coords[0],
        coords[1],
        25000,
      );

      if (nearbyAuxiliares.length > 0) {
        const userIds = nearbyAuxiliares.map((a) => a.userId);
        this.notificationsService
          .sendToUsers({
            userIds,
            type: NotificationType.RESCUE_ALERT,
            title: 'Urgent Rescue Alert (Expanded Search)',
            body: `A rescue alert ${alert.trackingCode} needs help -- expanded search area`,
            referenceId: alert.id,
            referenceType: 'RescueAlert',
          })
          .catch(() => {});
      }
    }

    return alert;
  }

  async findAlertById(id: string): Promise<RescueAlert> {
    return this.findAlertOrFail(id);
  }

  async findMyAlerts(
    userId: string,
    status?: RescueStatus,
  ): Promise<RescueAlert[]> {
    const where: any[] = [
      { reportedById: userId, ...(status ? { status } : {}) },
      { auxiliarId: userId, ...(status ? { status } : {}) },
      { rescuerId: userId, ...(status ? { status } : {}) },
    ];

    return this.rescueAlertRepository.find({
      where,
      order: { createdAt: 'DESC' },
    });
  }

  async findNearbyAlerts(
    latitude: number,
    longitude: number,
    radiusKm?: number,
  ): Promise<RescueAlert[]> {
    const radiusMeters = (radiusKm ?? 10) * 1000;

    // Use PostGIS ST_DWithin for spatial query on the geometry column
    const results = await this.rescueAlertRepository
      .createQueryBuilder('alert')
      .where(
        `ST_DWithin(alert.location, ST_SetSRID(ST_MakePoint(:lon, :lat), 4326)::geography, :radius)`,
      )
      .andWhere('alert.status IN (:...activeStatuses)', {
        activeStatuses: [
          RescueStatus.CREATED,
          RescueStatus.ASSIGNED,
          RescueStatus.ACCEPTED,
          RescueStatus.IN_PROGRESS,
        ],
      })
      .setParameters({ lon: longitude, lat: latitude, radius: radiusMeters })
      .orderBy('alert.createdAt', 'DESC')
      .getMany();

    return results;
  }

  private async findAlertOrFail(id: string): Promise<RescueAlert> {
    const alert = await this.rescueAlertRepository.findOne({ where: { id } });
    if (!alert) {
      throw new NotFoundException(`Rescue alert with ID ${id} not found`);
    }
    return alert;
  }
}
