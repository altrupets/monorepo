import { Injectable, BadRequestException } from '@nestjs/common';
import { RescueStatus } from './enums/rescue-status.enum';
import { RescueAlert } from './entities/rescue-alert.entity';

const VALID_TRANSITIONS: Record<RescueStatus, RescueStatus[]> = {
  [RescueStatus.CREATED]: [
    RescueStatus.ASSIGNED,
    RescueStatus.CANCELLED,
    RescueStatus.EXPIRED,
  ],
  [RescueStatus.ASSIGNED]: [
    RescueStatus.ACCEPTED,
    RescueStatus.REJECTED,
    RescueStatus.CANCELLED,
    RescueStatus.EXPIRED,
  ],
  [RescueStatus.ACCEPTED]: [
    RescueStatus.IN_PROGRESS,
    RescueStatus.CANCELLED,
  ],
  [RescueStatus.IN_PROGRESS]: [
    RescueStatus.TRANSFERRED,
    RescueStatus.CANCELLED,
  ],
  [RescueStatus.TRANSFERRED]: [
    RescueStatus.COMPLETED,
    RescueStatus.CANCELLED,
  ],
  [RescueStatus.COMPLETED]: [],
  [RescueStatus.CANCELLED]: [],
  [RescueStatus.REJECTED]: [],
  [RescueStatus.EXPIRED]: [],
};

@Injectable()
export class RescueStateMachine {
  canTransition(current: RescueStatus, target: RescueStatus): boolean {
    const allowed = VALID_TRANSITIONS[current];
    return allowed ? allowed.includes(target) : false;
  }

  transition(
    alert: RescueAlert,
    target: RescueStatus,
    actorId: string,
  ): RescueAlert {
    if (!this.canTransition(alert.status, target)) {
      throw new BadRequestException(
        `Cannot transition from ${alert.status} to ${target}`,
      );
    }

    alert.status = target;

    const now = new Date();

    switch (target) {
      case RescueStatus.ACCEPTED:
        alert.acceptedAt = now;
        alert.auxiliarId = actorId;
        break;
      case RescueStatus.TRANSFERRED:
        alert.transferredAt = now;
        break;
      case RescueStatus.COMPLETED:
        alert.completedAt = now;
        break;
    }

    return alert;
  }
}
