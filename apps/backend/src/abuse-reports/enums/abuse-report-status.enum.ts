import { registerEnumType } from '@nestjs/graphql';

export enum AbuseReportStatus {
  FILED = 'FILED',
  CLASSIFIED = 'CLASSIFIED',
  UNDER_INVESTIGATION = 'UNDER_INVESTIGATION',
  RESOLVED = 'RESOLVED',
  CLOSED = 'CLOSED',
}

registerEnumType(AbuseReportStatus, { name: 'AbuseReportStatus' });
