import { ObjectType, Field, Int, Float } from '@nestjs/graphql';

@ObjectType()
export class ReportMetrics {
  @Field(() => Int, { description: 'Total abuse reports filed' })
  totalReports: number;

  @Field(() => Float, { description: 'Average response time in hours' })
  avgResponseTimeHours: number;

  @Field(() => Float, { description: 'Resolution rate (0.0 to 1.0)' })
  resolutionRate: number;

  @Field(() => Int, { description: 'Reports pending classification' })
  pendingClassification: number;

  @Field(() => Int, { description: 'Reports under investigation' })
  underInvestigation: number;

  @Field(() => Int, { description: 'Reports resolved' })
  resolved: number;

  @Field(() => Int, { description: 'Scheduled field visits' })
  scheduledVisits: number;
}
