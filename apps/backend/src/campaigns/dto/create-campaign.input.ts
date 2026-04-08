import { InputType, Field, ID, Int, Float } from '@nestjs/graphql';

@InputType()
export class CreateCampaignInput {
  @Field(() => ID)
  municipalityId: string;

  @Field()
  title: string;

  @Field()
  location: string;

  @Field(() => Int)
  maxCapacity: number;

  @Field({ description: 'Surgery date in YYYY-MM-DD format' })
  surgeryDate: string;

  @Field({ nullable: true, description: 'Perifoneo date in YYYY-MM-DD format' })
  promotionDate?: string;

  @Field({ nullable: true, description: 'Registration open date in YYYY-MM-DD format' })
  registrationOpenDate?: string;

  @Field({ nullable: true, description: 'Registration close date in YYYY-MM-DD format' })
  registrationCloseDate?: string;

  @Field({ nullable: true, description: 'Orientation/charla date in YYYY-MM-DD format' })
  orientationDate?: string;

  @Field(() => Float, { defaultValue: 0 })
  budgetAllocated: number;

  @Field(() => [ID], { nullable: true })
  veterinarianIds?: string[];

  @Field({ nullable: true })
  notes?: string;
}
