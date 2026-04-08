import { InputType, Field, ID } from '@nestjs/graphql';
import { SubsidyRequestStatus } from '../entities/subsidy-request.entity';

@InputType()
export class SubsidyFiltersInput {
  @Field(() => ID, { nullable: true })
  municipalityId?: string;

  @Field(() => SubsidyRequestStatus, { nullable: true })
  status?: SubsidyRequestStatus;

  @Field({ nullable: true, description: 'Start date for date range filter' })
  dateFrom?: Date;

  @Field({ nullable: true, description: 'End date for date range filter' })
  dateTo?: Date;
}
