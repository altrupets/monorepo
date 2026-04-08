import { registerEnumType } from '@nestjs/graphql';

export enum AuditAction {
  AUTO_APPROVED = 'AUTO_APPROVED',
  MANUAL_APPROVED = 'MANUAL_APPROVED',
  REJECTED = 'REJECTED',
  SENT_TO_REVIEW = 'SENT_TO_REVIEW',
  EXPIRED = 'EXPIRED',
}

registerEnumType(AuditAction, { name: 'AuditAction' });
