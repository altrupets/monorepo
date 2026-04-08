import { ObjectType, Field, Float, Int } from '@nestjs/graphql';

@ObjectType()
export class CampaignMetrics {
  @Field(() => Int, { description: 'Total animals sterilized across all campaigns' })
  totalSterilized: number;

  @Field(() => Float, { description: 'Average cost per animal in colones' })
  avgCostPerAnimal: number;

  @Field(() => Int, { description: 'Number of distinct communities covered' })
  communitiesCovered: number;

  @Field(() => Int, { description: 'Total communities target' })
  communitiesTotal: number;

  @Field(() => Int, { description: 'Days until next campaign surgery date' })
  daysUntilNextCampaign: number;

  @Field(() => Int, { description: 'Total campaigns' })
  totalCampaigns: number;

  @Field(() => Int, { description: 'Active campaigns count' })
  activeCampaigns: number;

  @Field(() => Int, { description: 'Completed campaigns count' })
  completedCampaigns: number;
}
