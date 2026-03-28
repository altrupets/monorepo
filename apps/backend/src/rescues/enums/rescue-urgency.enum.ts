import { registerEnumType } from '@nestjs/graphql';

export enum RescueUrgency {
  LOW = 'LOW',
  MEDIUM = 'MEDIUM',
  HIGH = 'HIGH',
  CRITICAL = 'CRITICAL',
}

registerEnumType(RescueUrgency, { name: 'RescueUrgency' });
