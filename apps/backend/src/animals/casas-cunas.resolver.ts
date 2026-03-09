import { Resolver, Query, Mutation, Args, ID } from '@nestjs/graphql';
import { UseGuards } from '@nestjs/common';
import { CasaCuna } from './entities/casa-cuna.entity';
import { CasasCunasService } from './casas-cunas.service';
import { JwtAuthGuard } from '../auth/jwt-auth.guard';

@Resolver(() => CasaCuna)
export class CasasCunasResolver {
  constructor(private readonly casasCunasService: CasasCunasService) {}

  @Query(() => [CasaCuna], { name: 'casasCunas' })
  async getCasasCunas(): Promise<CasaCuna[]> {
    return this.casasCunasService.findAll();
  }

  @Query(() => [CasaCuna], { name: 'verifiedCasasCunas' })
  async getVerifiedCasasCunas(): Promise<CasaCuna[]> {
    return this.casasCunasService.findVerified();
  }

  @Query(() => CasaCuna, { name: 'casaCuna', nullable: true })
  async getCasaCuna(
    @Args('id', { type: () => ID }) id: string,
  ): Promise<CasaCuna> {
    return this.casasCunasService.findOne(id);
  }

  @Query(() => [CasaCuna], { name: 'casasCunasByOwner' })
  async getCasasCunasByOwner(
    @Args('ownerId', { type: () => ID }) ownerId: string,
  ): Promise<CasaCuna[]> {
    return this.casasCunasService.findByOwner(ownerId);
  }

  @Mutation(() => CasaCuna)
  @UseGuards(JwtAuthGuard)
  async createCasaCuna(
    @Args('name') name: string,
    @Args('description', { nullable: true }) description?: string,
    @Args('address', { nullable: true }) address?: string,
    @Args('province', { nullable: true }) province?: string,
    @Args('canton', { nullable: true }) canton?: string,
    @Args('district', { nullable: true }) district?: string,
    @Args('latitude', { nullable: true }) latitude?: number,
    @Args('longitude', { nullable: true }) longitude?: number,
    @Args('phone', { nullable: true }) phone?: string,
    @Args('email', { nullable: true }) email?: string,
    @Args('capacity', { nullable: true }) capacity?: number,
    @Args('contactPerson', { nullable: true }) contactPerson?: string,
  ): Promise<CasaCuna> {
    return this.casasCunasService.create({
      name,
      description,
      address,
      province,
      canton,
      district,
      latitude,
      longitude,
      phone,
      email,
      capacity,
      contactPerson,
    });
  }

  @Mutation(() => CasaCuna)
  @UseGuards(JwtAuthGuard)
  async updateCasaCuna(
    @Args('id', { type: () => ID }) id: string,
    @Args('name', { nullable: true }) name?: string,
    @Args('description', { nullable: true }) description?: string,
    @Args('address', { nullable: true }) address?: string,
    @Args('phone', { nullable: true }) phone?: string,
    @Args('email', { nullable: true }) email?: string,
    @Args('capacity', { nullable: true }) capacity?: number,
    @Args('isActive', { nullable: true }) isActive?: boolean,
    @Args('isVerified', { nullable: true }) isVerified?: boolean,
  ): Promise<CasaCuna> {
    return this.casasCunasService.update(id, {
      name,
      description,
      address,
      phone,
      email,
      capacity,
      isActive,
      isVerified,
    });
  }

  @Mutation(() => Boolean)
  @UseGuards(JwtAuthGuard)
  async deleteCasaCuna(
    @Args('id', { type: () => ID }) id: string,
  ): Promise<boolean> {
    await this.casasCunasService.remove(id);
    return true;
  }
}
