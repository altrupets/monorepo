import { InputType, Field, ID } from '@nestjs/graphql';

@InputType()
export class ResolveReportInput {
  @Field(() => ID)
  id: string;

  @Field({ description: 'Notes describing the resolution outcome' })
  resolutionNotes: string;
}
