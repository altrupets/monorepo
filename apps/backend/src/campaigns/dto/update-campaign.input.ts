import { InputType, Field, ID, Int, Float } from '@nestjs/graphql';

@InputType()
export class UpdateCampaignInput {
  @Field(() => ID)
  id: string;

  @Field({ nullable: true })
  title?: string;

  @Field({ nullable: true })
  location?: string;

  @Field(() => Int, { nullable: true })
  maxCapacity?: number;

  @Field({ nullable: true })
  surgeryDate?: string;

  @Field({ nullable: true })
  promotionDate?: string;

  @Field({ nullable: true })
  registrationOpenDate?: string;

  @Field({ nullable: true })
  registrationCloseDate?: string;

  @Field({ nullable: true })
  orientationDate?: string;

  @Field(() => Float, { nullable: true })
  budgetAllocated?: number;

  @Field(() => Float, { nullable: true })
  budgetSpent?: number;

  @Field(() => [ID], { nullable: true })
  veterinarianIds?: string[];

  @Field({ nullable: true })
  notes?: string;
}
