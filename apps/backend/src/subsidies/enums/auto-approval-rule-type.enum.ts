import { registerEnumType } from '@nestjs/graphql';

export enum AutoApprovalRuleType {
  VERIFIED_RESCUER = 'VERIFIED_RESCUER',
  REGISTERED_ANIMAL = 'REGISTERED_ANIMAL',
  WITHIN_BUDGET = 'WITHIN_BUDGET',
  AUTHORIZED_VET = 'AUTHORIZED_VET',
  NO_DUPLICATE = 'NO_DUPLICATE',
}

registerEnumType(AutoApprovalRuleType, { name: 'AutoApprovalRuleType' });
