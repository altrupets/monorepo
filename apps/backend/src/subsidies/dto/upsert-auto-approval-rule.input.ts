import { InputType, Field, ID } from '@nestjs/graphql';
import { AutoApprovalRuleType } from '../enums/auto-approval-rule-type.enum';
import { GraphQLJSON } from '../../notifications/scalars/json.scalar';

@InputType()
export class UpsertAutoApprovalRuleInput {
  @Field(() => ID)
  municipalityId: string;

  @Field(() => AutoApprovalRuleType)
  ruleType: AutoApprovalRuleType;

  @Field(() => Boolean, { defaultValue: true })
  isEnabled: boolean;

  @Field(() => GraphQLJSON, { nullable: true })
  parameters?: Record<string, any>;
}
