import { ObjectType, Field, Int, Float } from '@nestjs/graphql';
import { RescuerCandidate } from './rescuer-candidate.output';

@ObjectType()
export class MatchingResult {
  @Field(() => [RescuerCandidate])
  candidates: RescuerCandidate[];

  @Field(() => Int)
  totalEvaluated: number;

  @Field(() => Float)
  durationMs: number;
}
