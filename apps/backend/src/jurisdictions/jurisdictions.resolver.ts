import { Resolver, Query, Args, ID, Int } from '@nestjs/graphql';
import { Jurisdiction, JurisdictionLevel } from './entities/jurisdiction.entity';
import { JurisdictionsService } from './jurisdictions.service';

@Resolver(() => Jurisdiction)
export class JurisdictionsResolver {
  constructor(private readonly jurisdictionsService: JurisdictionsService) {}

  @Query(() => [Jurisdiction], { name: 'jurisdictions' })
  async getJurisdictions(): Promise<Jurisdiction[]> {
    return this.jurisdictionsService.findAll();
  }

  @Query(() => Jurisdiction, { name: 'jurisdiction', nullable: true })
  async getJurisdiction(
    @Args('id', { type: () => ID }) id: string,
  ): Promise<Jurisdiction> {
    return this.jurisdictionsService.findOne(id);
  }

  @Query(() => [Jurisdiction], { name: 'provinces' })
  async getProvinces(): Promise<Jurisdiction[]> {
    return this.jurisdictionsService.findProvinces();
  }

  @Query(() => [Jurisdiction], { name: 'cantons' })
  async getCantons(
    @Args('provinceId', { type: () => ID }) provinceId: string,
  ): Promise<Jurisdiction[]> {
    return this.jurisdictionsService.findCantons(provinceId);
  }

  @Query(() => [Jurisdiction], { name: 'districts' })
  async getDistricts(
    @Args('cantonId', { type: () => ID }) cantonId: string,
  ): Promise<Jurisdiction[]> {
    return this.jurisdictionsService.findDistricts(cantonId);
  }

  @Query(() => Jurisdiction, { name: 'jurisdictionByCoordinates', nullable: true })
  async getJurisdictionByCoordinates(
    @Args('latitude') latitude: number,
    @Args('longitude') longitude: number,
  ): Promise<Jurisdiction | null> {
    return this.jurisdictionsService.findByCoordinates(latitude, longitude);
  }
}
