import { registerEnumType } from '@nestjs/graphql';

export enum ProcedureType {
  STERILIZATION = 'STERILIZATION',
  VACCINATION = 'VACCINATION',
  EMERGENCY = 'EMERGENCY',
  SURGERY = 'SURGERY',
  CONSULTATION = 'CONSULTATION',
  DEWORMING = 'DEWORMING',
  OTHER = 'OTHER',
}

registerEnumType(ProcedureType, { name: 'ProcedureType' });
