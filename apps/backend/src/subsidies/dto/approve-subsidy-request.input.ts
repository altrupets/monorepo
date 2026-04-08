import { InputType, Field, ID } from '@nestjs/graphql';

@InputType()
export class ApproveSubsidyRequestInput {
  @Field(() => ID)
  id: string;

  @Field({ nullable: true })
  notes?: string;
}
