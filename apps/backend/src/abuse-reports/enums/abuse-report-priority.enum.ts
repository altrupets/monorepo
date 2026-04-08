import { registerEnumType } from '@nestjs/graphql';

export enum AbuseReportPriority {
  LOW = 'LOW',
  MEDIUM = 'MEDIUM',
  HIGH = 'HIGH',
  CRITICAL = 'CRITICAL',
}

registerEnumType(AbuseReportPriority, { name: 'AbuseReportPriority' });
