import { registerEnumType } from '@nestjs/graphql';

export enum ApplicationStatus {
  SUBMITTED = 'SUBMITTED',
  IN_REVIEW = 'IN_REVIEW',
  VISIT_SCHEDULED = 'VISIT_SCHEDULED',
  VISIT_COMPLETED = 'VISIT_COMPLETED',
  APPROVED = 'APPROVED',
  REJECTED = 'REJECTED',
}

registerEnumType(ApplicationStatus, { name: 'ApplicationStatus' });
