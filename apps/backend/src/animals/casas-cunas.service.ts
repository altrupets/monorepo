import { Injectable, NotFoundException } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { CasaCuna } from './entities/casa-cuna.entity';

@Injectable()
export class CasasCunasService {
  constructor(
    @InjectRepository(CasaCuna)
    private readonly casaCunaRepository: Repository<CasaCuna>,
  ) {}

  async findAll(): Promise<CasaCuna[]> {
    return this.casaCunaRepository.find({
      where: { isActive: true },
      order: { name: 'ASC' },
    });
  }

  async findOne(id: string): Promise<CasaCuna> {
    const casaCuna = await this.casaCunaRepository.findOne({
      where: { id },
      relations: ['animals'],
    });
    if (!casaCuna) {
      throw new NotFoundException(`CasaCuna with ID ${id} not found`);
    }
    return casaCuna;
  }

  async findVerified(): Promise<CasaCuna[]> {
    return this.casaCunaRepository.find({
      where: { isActive: true, isVerified: true },
      order: { name: 'ASC' },
    });
  }

  async findByOwner(ownerId: string): Promise<CasaCuna[]> {
    return this.casaCunaRepository.find({
      where: { ownerId },
      order: { name: 'ASC' },
    });
  }

  async create(data: Partial<CasaCuna>): Promise<CasaCuna> {
    const casaCuna = this.casaCunaRepository.create(data);
    return this.casaCunaRepository.save(casaCuna);
  }

  async update(id: string, data: Partial<CasaCuna>): Promise<CasaCuna> {
    const casaCuna = await this.findOne(id);
    Object.assign(casaCuna, data);
    return this.casaCunaRepository.save(casaCuna);
  }

  async remove(id: string): Promise<void> {
    const casaCuna = await this.findOne(id);
    await this.casaCunaRepository.remove(casaCuna);
  }
}
