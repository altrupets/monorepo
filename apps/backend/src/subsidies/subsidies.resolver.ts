import { Resolver, Query, Mutation, Args, ID, Float } from '@nestjs/graphql';
import { UseGuards } from '@nestjs/common';
import { SubsidyRequest, SubsidyRequestStatus } from './entities/subsidy-request.entity';
import { SubsidiesService } from './subsidies.service';
import { JwtAuthGuard } from '../auth/jwt-auth.guard';
import { GqlUser } from '../auth/gql-user.decorator';
import { User } from '../users/entities/user.entity';

@Resolver(() => SubsidyRequest)
export class SubsidiesResolver {
  constructor(private readonly subsidiesService: SubsidiesService) {}

  @Mutation(() => SubsidyRequest)
  @UseGuards(JwtAuthGuard)
  async createSubsidyRequest(
    @GqlUser() user: User,
    @Args('animalId', { type: () => ID }) animalId: string,
    @Args('amountRequested', { type: () => Float }) amountRequested: number,
    @Args('justification') justification: string,
  ): Promise<SubsidyRequest> {
    return this.subsidiesService.create({
      animalId,
      amountRequested,
      justification,
      requesterId: user.id,
    });
  }

  @Query(() => SubsidyRequest, { name: 'subsidyRequest' })
  @UseGuards(JwtAuthGuard)
  async getSubsidyRequest(
    @Args('id', { type: () => ID }) id: string,
  ): Promise<SubsidyRequest> {
    return this.subsidiesService.findOne(id);
  }

  @Query(() => [SubsidyRequest], { name: 'mySubsidyRequests' })
  @UseGuards(JwtAuthGuard)
  async getMySubsidyRequests(
    @GqlUser() user: User,
  ): Promise<SubsidyRequest[]> {
    return this.subsidiesService.findAllByRequester(user.id);
  }

  @Mutation(() => SubsidyRequest)
  @UseGuards(JwtAuthGuard)
  async updateSubsidyStatus(
    @Args('id', { type: () => ID }) id: string,
    @Args('status', { type: () => SubsidyRequestStatus }) status: SubsidyRequestStatus,
  ): Promise<SubsidyRequest> {
    return this.subsidiesService.updateStatus(id, status);
  }
}
