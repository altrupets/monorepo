import { Resolver, Query, Mutation, Args, ID } from '@nestjs/graphql';
import { UseGuards } from '@nestjs/common';
import { VetProfile } from './entities/vet-profile.entity';
import { CreateVetProfileInput, UpdateVetProfileInput } from './dto/vet-profile.input';
import { VetProfilesService } from './vet-profiles.service';
import { JwtAuthGuard } from '../auth/jwt-auth.guard';
import { GqlUser } from '../auth/gql-user.decorator';
import { User } from '../users/entities/user.entity';

@Resolver(() => VetProfile)
export class VetProfilesResolver {
  constructor(private readonly vetProfilesService: VetProfilesService) {}

  @Query(() => [VetProfile], { name: 'vetProfiles' })
  async getVetProfiles(): Promise<VetProfile[]> {
    return this.vetProfilesService.findAll();
  }

  @Query(() => [VetProfile], { name: 'verifiedVetProfiles' })
  async getVerifiedVetProfiles(): Promise<VetProfile[]> {
    return this.vetProfilesService.findVerified();
  }

  @Query(() => VetProfile, { name: 'vetProfile', nullable: true })
  async getVetProfile(
    @Args('id', { type: () => ID }) id: string,
  ): Promise<VetProfile> {
    return this.vetProfilesService.findOne(id);
  }

  @Query(() => VetProfile, { name: 'vetProfileByUser', nullable: true })
  async getVetProfileByUser(
    @Args('userId', { type: () => ID }) userId: string,
  ): Promise<VetProfile | null> {
    return this.vetProfilesService.findByUserId(userId);
  }

  @Mutation(() => VetProfile)
  @UseGuards(JwtAuthGuard)
  async createVetProfile(
    @Args('input') input: CreateVetProfileInput,
    @GqlUser() user: User,
  ): Promise<VetProfile> {
    return this.vetProfilesService.create(input, user.id);
  }

  @Mutation(() => VetProfile)
  @UseGuards(JwtAuthGuard)
  async updateVetProfile(
    @Args('id', { type: () => ID }) id: string,
    @Args('input') input: UpdateVetProfileInput,
    @GqlUser() user: User,
  ): Promise<VetProfile> {
    return this.vetProfilesService.update(id, input, user.id);
  }

  @Mutation(() => Boolean)
  @UseGuards(JwtAuthGuard)
  async deleteVetProfile(
    @Args('id', { type: () => ID }) id: string,
    @GqlUser() user: User,
  ): Promise<boolean> {
    await this.vetProfilesService.remove(id, user.id);
    return true;
  }
}
