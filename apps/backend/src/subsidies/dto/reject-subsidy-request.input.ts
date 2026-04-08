import { InputType, Field, ID } from '@nestjs/graphql';

@InputType()
export class RejectSubsidyRequestInput {
  @Field(() => ID)
  id: string;

  @Field()
  rejectionReason: string;

  @Field({ nullable: true })
  notes?: string;
}
