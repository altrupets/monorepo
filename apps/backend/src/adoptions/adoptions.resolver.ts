import { Resolver, Query, Mutation, Args, ID, Int } from '@nestjs/graphql';
import { UseGuards } from '@nestjs/common';
import { AdoptionListing } from './entities/adoption-listing.entity';
import { AdoptionsService } from './adoptions.service';
import { CreateAdoptionListingInput } from './dto/create-adoption-listing.input';
import { UpdateAdoptionListingInput } from './dto/update-adoption-listing.input';
import { AdoptionListingFilterInput } from './dto/adoption-listing-filter.input';
import { ListingStatus } from './enums/listing-status.enum';
import { JwtAuthGuard } from '../auth/jwt-auth.guard';
import { GqlUser } from '../auth/gql-user.decorator';
import { User } from '../users/entities/user.entity';

@Resolver(() => AdoptionListing)
export class AdoptionsResolver {
  constructor(private readonly adoptionsService: AdoptionsService) {}

  @Query(() => [AdoptionListing], { name: 'adoptionListings' })
  @UseGuards(JwtAuthGuard)
  async getAdoptionListings(
    @Args('filter', { type: () => AdoptionListingFilterInput, nullable: true })
    filter?: AdoptionListingFilterInput,
    @Args('first', { type: () => Int, nullable: true }) first?: number,
    @Args('after', { type: () => String, nullable: true }) after?: string,
  ): Promise<AdoptionListing[]> {
    return this.adoptionsService.findListings(filter, first, after);
  }

  @Query(() => AdoptionListing, { name: 'adoptionListing' })
  @UseGuards(JwtAuthGuard)
  async getAdoptionListing(
    @Args('id', { type: () => ID }) id: string,
  ): Promise<AdoptionListing> {
    return this.adoptionsService.findById(id);
  }

  @Query(() => [AdoptionListing], { name: 'myAdoptionListings' })
  @UseGuards(JwtAuthGuard)
  async getMyAdoptionListings(
    @GqlUser() user: User,
    @Args('status', { type: () => ListingStatus, nullable: true })
    status?: ListingStatus,
  ): Promise<AdoptionListing[]> {
    return this.adoptionsService.findMyListings(user.id, status);
  }

  @Mutation(() => AdoptionListing)
  @UseGuards(JwtAuthGuard)
  async createAdoptionListing(
    @GqlUser() user: User,
    @Args('input') input: CreateAdoptionListingInput,
  ): Promise<AdoptionListing> {
    return this.adoptionsService.createListing(input, user.id);
  }

  @Mutation(() => AdoptionListing)
  @UseGuards(JwtAuthGuard)
  async publishAdoptionListing(
    @GqlUser() user: User,
    @Args('listingId', { type: () => ID }) listingId: string,
  ): Promise<AdoptionListing> {
    return this.adoptionsService.publishListing(listingId, user.id);
  }

  @Mutation(() => AdoptionListing)
  @UseGuards(JwtAuthGuard)
  async pauseAdoptionListing(
    @GqlUser() user: User,
    @Args('listingId', { type: () => ID }) listingId: string,
  ): Promise<AdoptionListing> {
    return this.adoptionsService.pauseListing(listingId, user.id);
  }

  @Mutation(() => AdoptionListing)
  @UseGuards(JwtAuthGuard)
  async reactivateAdoptionListing(
    @GqlUser() user: User,
    @Args('listingId', { type: () => ID }) listingId: string,
  ): Promise<AdoptionListing> {
    return this.adoptionsService.reactivateListing(listingId, user.id);
  }

  @Mutation(() => AdoptionListing)
  @UseGuards(JwtAuthGuard)
  async closeAdoptionListing(
    @GqlUser() user: User,
    @Args('listingId', { type: () => ID }) listingId: string,
    @Args('reason') reason: 'ADOPTED' | 'WITHDRAWN',
  ): Promise<AdoptionListing> {
    return this.adoptionsService.closeListing(listingId, user.id, reason);
  }

  @Mutation(() => AdoptionListing)
  @UseGuards(JwtAuthGuard)
  async updateAdoptionListing(
    @GqlUser() user: User,
    @Args('listingId', { type: () => ID }) listingId: string,
    @Args('input') input: UpdateAdoptionListingInput,
  ): Promise<AdoptionListing> {
    return this.adoptionsService.updateListing(listingId, user.id, input);
  }
}
