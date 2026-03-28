import { ObjectType, Field, ID, Float, Int } from '@nestjs/graphql';
import { GraphQLJSON } from '../../notifications/scalars/json.scalar';

@ObjectType()
export class RescuerCandidate {
  @Field(() => ID)
  userId: string;

  @Field()
  name: string;

  @Field(() => Float)
  distanceKm: number;

  @Field(() => Int)
  availableCapacity: number;

  @Field(() => Float)
  score: number;

  @Field()
  explanation: string;

  @Field(() => GraphQLJSON, { nullable: true })
  scoreBreakdown?: Record<string, number>;
}
