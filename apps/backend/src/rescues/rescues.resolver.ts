import { Resolver, Query, Mutation, Args, ID, Float } from '@nestjs/graphql';
import { UseGuards } from '@nestjs/common';
import { RescueAlert } from './entities/rescue-alert.entity';
import { RescueStatus } from './enums/rescue-status.enum';
import { RescuesService } from './rescues.service';
import { RescueMatchingService } from './rescue-matching.service';
import { CreateRescueAlertInput } from './dto/create-rescue-alert.input';
import { UpdateRescueProgressInput } from './dto/update-rescue-progress.input';
import { CompleteRescueInput } from './dto/complete-rescue.input';
import { JwtAuthGuard } from '../auth/jwt-auth.guard';
import { GqlUser } from '../auth/gql-user.decorator';
import { User } from '../users/entities/user.entity';

@Resolver(() => RescueAlert)
export class RescuesResolver {
  constructor(
    private readonly rescuesService: RescuesService,
    private readonly matchingService: RescueMatchingService,
  ) {}

  // -- Mutations --

  @Mutation(() => RescueAlert)
  @UseGuards(JwtAuthGuard)
  async createRescueAlert(
    @Args('input') input: CreateRescueAlertInput,
    @GqlUser() user: User,
  ): Promise<RescueAlert> {
    return this.rescuesService.createAlert(input, user.id);
  }

  @Mutation(() => RescueAlert)
  @UseGuards(JwtAuthGuard)
  async acceptRescueAlert(
    @Args('alertId', { type: () => ID }) alertId: string,
    @GqlUser() user: User,
  ): Promise<RescueAlert> {
    return this.rescuesService.acceptAlert(alertId, user.id);
  }

  @Mutation(() => RescueAlert)
  @UseGuards(JwtAuthGuard)
  async rejectRescueAlert(
    @Args('alertId', { type: () => ID }) alertId: string,
    @Args('reason', { nullable: true }) reason: string,
    @GqlUser() user: User,
  ): Promise<RescueAlert> {
    return this.rescuesService.rejectAlert(alertId, user.id, reason);
  }

  @Mutation(() => RescueAlert)
  @UseGuards(JwtAuthGuard)
  async updateRescueProgress(
    @Args('input') input: UpdateRescueProgressInput,
    @GqlUser() user: User,
  ): Promise<RescueAlert> {
    return this.rescuesService.updateProgress(input, user.id);
  }

  @Mutation(() => RescueAlert)
  @UseGuards(JwtAuthGuard)
  async requestRescueTransfer(
    @Args('alertId', { type: () => ID }) alertId: string,
    @GqlUser() user: User,
  ): Promise<RescueAlert> {
    return this.rescuesService.requestTransfer(alertId, user.id);
  }

  @Mutation(() => RescueAlert)
  @UseGuards(JwtAuthGuard)
  async acceptRescueTransfer(
    @Args('alertId', { type: () => ID }) alertId: string,
    @GqlUser() user: User,
  ): Promise<RescueAlert> {
    return this.rescuesService.acceptTransfer(alertId, user.id);
  }

  @Mutation(() => RescueAlert)
  @UseGuards(JwtAuthGuard)
  async completeRescue(
    @Args('input') input: CompleteRescueInput,
    @GqlUser() user: User,
  ): Promise<RescueAlert> {
    return this.rescuesService.completeRescue(input, user.id);
  }

  @Mutation(() => RescueAlert)
  @UseGuards(JwtAuthGuard)
  async cancelRescueAlert(
    @Args('alertId', { type: () => ID }) alertId: string,
    @Args('reason', { nullable: true }) reason: string,
    @GqlUser() user: User,
  ): Promise<RescueAlert> {
    return this.rescuesService.cancelAlert(alertId, user.id, reason);
  }

  @Mutation(() => Boolean)
  @UseGuards(JwtAuthGuard)
  async updateMyLocation(
    @Args('latitude', { type: () => Float }) latitude: number,
    @Args('longitude', { type: () => Float }) longitude: number,
    @GqlUser() user: User,
  ): Promise<boolean> {
    await this.matchingService.updateUserLocation(user.id, latitude, longitude);
    return true;
  }

  // -- Queries --

  @Query(() => RescueAlert, { name: 'rescueAlert' })
  @UseGuards(JwtAuthGuard)
  async getRescueAlert(
    @Args('id', { type: () => ID }) id: string,
  ): Promise<RescueAlert> {
    return this.rescuesService.findAlertById(id);
  }

  @Query(() => [RescueAlert], { name: 'myRescueAlerts' })
  @UseGuards(JwtAuthGuard)
  async getMyRescueAlerts(
    @GqlUser() user: User,
    @Args('status', { type: () => RescueStatus, nullable: true })
    status?: RescueStatus,
  ): Promise<RescueAlert[]> {
    return this.rescuesService.findMyAlerts(user.id, status);
  }

  @Query(() => [RescueAlert], { name: 'nearbyRescueAlerts' })
  @UseGuards(JwtAuthGuard)
  async getNearbyRescueAlerts(
    @Args('latitude', { type: () => Float }) latitude: number,
    @Args('longitude', { type: () => Float }) longitude: number,
    @Args('radiusKm', { type: () => Float, nullable: true }) radiusKm?: number,
  ): Promise<RescueAlert[]> {
    return this.rescuesService.findNearbyAlerts(latitude, longitude, radiusKm);
  }
}
