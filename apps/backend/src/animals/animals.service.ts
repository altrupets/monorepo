import { Injectable, NotFoundException } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { Animal, AnimalStatus } from './entities/animal.entity';

@Injectable()
export class AnimalsService {
  constructor(
    @InjectRepository(Animal)
    private readonly animalRepository: Repository<Animal>,
  ) {}

  async findAll(): Promise<Animal[]> {
    return this.animalRepository.find({
      order: { createdAt: 'DESC' },
    });
  }

  async findOne(id: string): Promise<Animal> {
    const animal = await this.animalRepository.findOne({
      where: { id },
    });
    if (!animal) {
      throw new NotFoundException(`Animal with ID ${id} not found`);
    }
    return animal;
  }

  async findByStatus(status: AnimalStatus): Promise<Animal[]> {
    return this.animalRepository.find({
      where: { status },
      order: { createdAt: 'DESC' },
    });
  }

  async findByCasaCuna(casaCunaId: string): Promise<Animal[]> {
    return this.animalRepository.find({
      where: { casaCunaId },
      order: { createdAt: 'DESC' },
    });
  }

  async create(data: Partial<Animal>): Promise<Animal> {
    const animal = this.animalRepository.create(data);
    return this.animalRepository.save(animal);
  }

  async update(id: string, data: Partial<Animal>): Promise<Animal> {
    const animal = await this.findOne(id);
    Object.assign(animal, data);
    return this.animalRepository.save(animal);
  }

  async remove(id: string): Promise<void> {
    const animal = await this.findOne(id);
    await this.animalRepository.remove(animal);
  }

  async findRescued(): Promise<Animal[]> {
    return this.findByStatus(AnimalStatus.RESCUED);
  }

  async findAdopted(): Promise<Animal[]> {
    return this.findByStatus(AnimalStatus.ADOPTED);
  }

  async findInCasaCuna(): Promise<Animal[]> {
    return this.findByStatus(AnimalStatus.IN_CASA_CUNA);
  }
}
