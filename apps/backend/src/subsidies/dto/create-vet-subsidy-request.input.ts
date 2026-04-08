import { InputType, Field, ID, Float } from '@nestjs/graphql';
import { ProcedureType } from '../enums/procedure-type.enum';

@InputType()
export class CreateVetSubsidyRequestInput {
  @Field(() => ID)
  animalId: string;

  @Field(() => Float)
  amountRequested: number;

  @Field()
  justification: string;

  @Field(() => ID, { nullable: true })
  vetProfileId?: string;

  @Field(() => ProcedureType, { nullable: true })
  procedureType?: ProcedureType;
}
