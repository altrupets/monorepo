import { Resolver, Query, Mutation, Args, ID } from '@nestjs/graphql';
import { UseGuards } from '@nestjs/common';
import { AdoptionApplication } from './entities/adoption-application.entity';
import { AdoptionApplicationsService } from './adoption-applications.service';
import { SubmitAdoptionApplicationInput } from './dto/submit-adoption-application.input';
import { ApplicationStatus } from './enums/application-status.enum';
import { JwtAuthGuard } from '../auth/jwt-auth.guard';
import { GqlUser } from '../auth/gql-user.decorator';
import { User } from '../users/entities/user.entity';

@Resolver(() => AdoptionApplication)
export class AdoptionApplicationsResolver {
  constructor(
    private readonly applicationsService: AdoptionApplicationsService,
  ) {}

  @Query(() => [AdoptionApplication], { name: 'adoptionApplications' })
  @UseGuards(JwtAuthGuard)
  async getAdoptionApplications(
    @Args('listingId', { type: () => ID }) listingId: string,
    @Args('status', { type: () => ApplicationStatus, nullable: true })
    status?: ApplicationStatus,
  ): Promise<AdoptionApplication[]> {
    return this.applicationsService.findByListing(listingId, status);
  }

  @Query(() => [AdoptionApplication], { name: 'myAdoptionApplications' })
  @UseGuards(JwtAuthGuard)
  async getMyAdoptionApplications(
    @GqlUser() user: User,
  ): Promise<AdoptionApplication[]> {
    return this.applicationsService.findMyApplications(user.id);
  }

  @Mutation(() => AdoptionApplication)
  @UseGuards(JwtAuthGuard)
  async submitAdoptionApplication(
    @GqlUser() user: User,
    @Args('input') input: SubmitAdoptionApplicationInput,
  ): Promise<AdoptionApplication> {
    return this.applicationsService.submit(input, user.id);
  }

  @Mutation(() => AdoptionApplication)
  @UseGuards(JwtAuthGuard)
  async reviewAdoptionApplication(
    @GqlUser() user: User,
    @Args('applicationId', { type: () => ID }) applicationId: string,
  ): Promise<AdoptionApplication> {
    return this.applicationsService.review(applicationId, user.id);
  }

  @Mutation(() => AdoptionApplication)
  @UseGuards(JwtAuthGuard)
  async scheduleVisit(
    @GqlUser() user: User,
    @Args('applicationId', { type: () => ID }) applicationId: string,
    @Args('scheduledDate') scheduledDate: Date,
  ): Promise<AdoptionApplication> {
    return this.applicationsService.scheduleVisit(
      applicationId,
      user.id,
      scheduledDate,
    );
  }

  @Mutation(() => AdoptionApplication)
  @UseGuards(JwtAuthGuard)
  async completeVisit(
    @GqlUser() user: User,
    @Args('applicationId', { type: () => ID }) applicationId: string,
    @Args('notes') notes: string,
  ): Promise<AdoptionApplication> {
    return this.applicationsService.completeVisit(
      applicationId,
      user.id,
      notes,
    );
  }

  @Mutation(() => AdoptionApplication)
  @UseGuards(JwtAuthGuard)
  async approveAdoptionApplication(
    @GqlUser() user: User,
    @Args('applicationId', { type: () => ID }) applicationId: string,
  ): Promise<AdoptionApplication> {
    return this.applicationsService.approve(applicationId, user.id);
  }

  @Mutation(() => AdoptionApplication)
  @UseGuards(JwtAuthGuard)
  async rejectAdoptionApplication(
    @GqlUser() user: User,
    @Args('applicationId', { type: () => ID }) applicationId: string,
    @Args('reason') reason: string,
  ): Promise<AdoptionApplication> {
    return this.applicationsService.reject(applicationId, user.id, reason);
  }
}
