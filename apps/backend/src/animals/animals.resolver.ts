import { Resolver, Query, Mutation, Args, ID } from '@nestjs/graphql';
import { UseGuards } from '@nestjs/common';
import { Animal, AnimalSpecies, AnimalStatus } from './entities/animal.entity';
import { AnimalsService } from './animals.service';
import { JwtAuthGuard } from '../auth/jwt-auth.guard';

@Resolver(() => Animal)
export class AnimalsResolver {
  constructor(private readonly animalsService: AnimalsService) {}

  @Query(() => [Animal], { name: 'animals' })
  async getAnimals(): Promise<Animal[]> {
    return this.animalsService.findAll();
  }

  @Query(() => [Animal], { name: 'rescuedAnimals' })
  async getRescuedAnimals(): Promise<Animal[]> {
    return this.animalsService.findRescued();
  }

  @Query(() => [Animal], { name: 'adoptedAnimals' })
  async getAdoptedAnimals(): Promise<Animal[]> {
    return this.animalsService.findAdopted();
  }

  @Query(() => [Animal], { name: 'animalsInCasaCuna' })
  async getAnimalsInCasaCuna(): Promise<Animal[]> {
    return this.animalsService.findInCasaCuna();
  }

  @Query(() => Animal, { name: 'animal', nullable: true })
  async getAnimal(
    @Args('id', { type: () => ID }) id: string,
  ): Promise<Animal> {
    return this.animalsService.findOne(id);
  }

  @Query(() => [Animal], { name: 'animalsByCasaCuna' })
  async getAnimalsByCasaCuna(
    @Args('casaCunaId', { type: () => ID }) casaCunaId: string,
  ): Promise<Animal[]> {
    return this.animalsService.findByCasaCuna(casaCunaId);
  }

  @Mutation(() => Animal)
  @UseGuards(JwtAuthGuard)
  async createAnimal(
    @Args('name') name: string,
    @Args('species') species: AnimalSpecies,
    @Args('breed', { nullable: true }) breed?: string,
    @Args('age', { nullable: true }) age?: string,
    @Args('gender', { nullable: true }) gender?: string,
    @Args('description', { nullable: true }) description?: string,
    @Args('latitude', { nullable: true }) latitude?: number,
    @Args('longitude', { nullable: true }) longitude?: number,
    @Args('rescueLocation', { nullable: true }) rescueLocation?: string,
  ): Promise<Animal> {
    return this.animalsService.create({
      name,
      species,
      breed,
      age,
      gender,
      description,
      location:
        latitude !== undefined && longitude !== undefined
          ? { type: 'Point', coordinates: [longitude, latitude] }
          : undefined,
      rescueLocation,
      status: AnimalStatus.RESCUED,
    });
  }

  @Mutation(() => Animal)
  @UseGuards(JwtAuthGuard)
  async updateAnimal(
    @Args('id', { type: () => ID }) id: string,
    @Args('name', { nullable: true }) name?: string,
    @Args('status', { nullable: true }) status?: AnimalStatus,
    @Args('casaCunaId', { nullable: true }) casaCunaId?: string,
    @Args('description', { nullable: true }) description?: string,
    @Args('veterinaryNotes', { nullable: true }) veterinaryNotes?: string,
  ): Promise<Animal> {
    return this.animalsService.update(id, {
      name,
      status,
      casaCunaId,
      description,
      veterinaryNotes,
    });
  }

  @Mutation(() => Boolean)
  @UseGuards(JwtAuthGuard)
  async deleteAnimal(
    @Args('id', { type: () => ID }) id: string,
  ): Promise<boolean> {
    await this.animalsService.remove(id);
    return true;
  }
}
