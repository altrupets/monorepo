import { BadRequestException } from '@nestjs/common';
import { CampaignStatus } from './enums/campaign-status.enum';

/**
 * Campaign status state machine.
 *
 * Valid transitions:
 *   DRAFT -> PUBLISHED -> REGISTRATION_OPEN -> REGISTRATION_CLOSED -> IN_PROGRESS -> COMPLETED -> ARCHIVED
 */
const STATUS_TRANSITIONS: Record<CampaignStatus, CampaignStatus | null> = {
  [CampaignStatus.DRAFT]: CampaignStatus.PUBLISHED,
  [CampaignStatus.PUBLISHED]: CampaignStatus.REGISTRATION_OPEN,
  [CampaignStatus.REGISTRATION_OPEN]: CampaignStatus.REGISTRATION_CLOSED,
  [CampaignStatus.REGISTRATION_CLOSED]: CampaignStatus.IN_PROGRESS,
  [CampaignStatus.IN_PROGRESS]: CampaignStatus.COMPLETED,
  [CampaignStatus.COMPLETED]: CampaignStatus.ARCHIVED,
  [CampaignStatus.ARCHIVED]: null,
};

/**
 * Returns the next valid status for a campaign, or throws if no transition exists.
 */
export function getNextCampaignStatus(currentStatus: CampaignStatus): CampaignStatus {
  const next = STATUS_TRANSITIONS[currentStatus];
  if (!next) {
    throw new BadRequestException(
      `Cannot advance campaign from status ${currentStatus} — it is already in its final state.`,
    );
  }
  return next;
}

/**
 * Returns true if the transition from `current` to `target` is valid.
 */
export function isValidTransition(current: CampaignStatus, target: CampaignStatus): boolean {
  return STATUS_TRANSITIONS[current] === target;
}

/**
 * Returns the step index (0-based) for the campaign stepper UI.
 *
 * Steps: Plan(0) -> Promo(1) -> Inscripcion(2) -> Cirugia(3) -> Seguimiento(4)
 */
export function campaignStatusToStepIndex(status: CampaignStatus): number {
  switch (status) {
    case CampaignStatus.DRAFT:
    case CampaignStatus.PUBLISHED:
      return 0; // Plan
    case CampaignStatus.REGISTRATION_OPEN:
    case CampaignStatus.REGISTRATION_CLOSED:
      return 2; // Inscripcion
    case CampaignStatus.IN_PROGRESS:
      return 3; // Cirugia
    case CampaignStatus.COMPLETED:
    case CampaignStatus.ARCHIVED:
      return 4; // Seguimiento
    default:
      return 0;
  }
}
