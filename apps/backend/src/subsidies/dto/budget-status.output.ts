import { ObjectType, Field, Float, Int } from '@nestjs/graphql';

@ObjectType()
export class BudgetStatus {
  @Field(() => Float)
  monthlyBudget: number;

  @Field(() => Float)
  disbursed: number;

  @Field(() => Float)
  available: number;

  @Field(() => Float, { description: 'Percentage of budget used (0-100)' })
  usagePercent: number;

  @Field(() => Int)
  totalRequests: number;

  @Field(() => Int)
  approvedCount: number;

  @Field(() => Int)
  inReviewCount: number;

  @Field(() => Int)
  rejectedCount: number;

  @Field(() => Int)
  daysRemainingInMonth: number;
}
