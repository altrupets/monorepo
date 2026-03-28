import { registerEnumType } from '@nestjs/graphql';

export enum RescueStatus {
  CREATED = 'CREATED',
  ASSIGNED = 'ASSIGNED',
  ACCEPTED = 'ACCEPTED',
  IN_PROGRESS = 'IN_PROGRESS',
  TRANSFERRED = 'TRANSFERRED',
  COMPLETED = 'COMPLETED',
  CANCELLED = 'CANCELLED',
  REJECTED = 'REJECTED',
  EXPIRED = 'EXPIRED',
}

registerEnumType(RescueStatus, { name: 'RescueStatus' });
