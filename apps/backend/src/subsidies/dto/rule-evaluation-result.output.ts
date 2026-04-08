import { ObjectType, Field } from '@nestjs/graphql';
import { AutoApprovalRuleType } from '../enums/auto-approval-rule-type.enum';

@ObjectType()
export class RuleEvaluationResult {
  @Field(() => AutoApprovalRuleType)
  ruleType: AutoApprovalRuleType;

  @Field(() => Boolean)
  passed: boolean;

  @Field()
  reason: string;

  @Field({ nullable: true })
  detail?: string;
}
