import { Resolver, Query, Mutation, Args, ID } from '@nestjs/graphql';
import { UseGuards } from '@nestjs/common';
import { MatchingService } from './matching.service';
import { MatchingInput } from './dto/matching-input.input';
import { MatchingResult } from './dto/matching-result.output';
import { JwtAuthGuard } from '../auth/jwt-auth.guard';

@Resolver()
export class MatchingResolver {
  constructor(private readonly matchingService: MatchingService) {}

  @Mutation(() => MatchingResult)
  @UseGuards(JwtAuthGuard)
  async requestRescuerMatching(
    @Args('input') input: MatchingInput,
  ): Promise<MatchingResult> {
    const result = await this.matchingService.findBestRescuers(
      input.rescueAlertId,
      input.latitude ?? 0,
      input.longitude ?? 0,
      input.urgency,
      input.animalType,
      input.maxCandidates,
    );

    return {
      candidates: result.candidates,
      totalEvaluated: result.totalEvaluated,
      durationMs: result.durationMs,
    };
  }

  @Query(() => MatchingResult, { name: 'matchingResult', nullable: true })
  @UseGuards(JwtAuthGuard)
  async getMatchingResult(
    @Args('rescueAlertId', { type: () => ID }) rescueAlertId: string,
  ): Promise<MatchingResult | null> {
    // Query the sidecar for the latest matching result for this alert.
    // The sidecar returns the most recent cached result when called
    // with the same rescueAlertId and zero coordinates.
    const result = await this.matchingService.findBestRescuers(
      rescueAlertId,
      0,
      0,
    );

    if (result.candidates.length === 0 && result.totalEvaluated === 0) {
      return null;
    }

    return {
      candidates: result.candidates,
      totalEvaluated: result.totalEvaluated,
      durationMs: result.durationMs,
    };
  }
}
