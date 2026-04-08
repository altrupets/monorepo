import { InputType, Field, ID } from '@nestjs/graphql';
import { AbuseReportPriority } from '../enums/abuse-report-priority.enum';

@InputType()
export class ClassifyReportInput {
  @Field(() => ID)
  id: string;

  @Field({ description: 'Classification label assigned by the officer' })
  classifiedAs: string;

  @Field(() => AbuseReportPriority, { description: 'Priority level assigned' })
  priority: AbuseReportPriority;
}
