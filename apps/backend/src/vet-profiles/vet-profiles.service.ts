import { Injectable, NotFoundException } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { VetProfile } from './entities/vet-profile.entity';
import { CreateVetProfileInput, UpdateVetProfileInput } from './dto/vet-profile.input';

@Injectable()
export class VetProfilesService {
  constructor(
    @InjectRepository(VetProfile)
    private readonly vetProfileRepository: Repository<VetProfile>,
  ) {}

  async findAll(): Promise<VetProfile[]> {
    return this.vetProfileRepository.find({
      where: { isActive: true },
      order: { createdAt: 'DESC' },
    });
  }

  async findOne(id: string): Promise<VetProfile> {
    const profile = await this.vetProfileRepository.findOne({
      where: { id },
    });
    if (!profile) {
      throw new NotFoundException(`VetProfile with ID ${id} not found`);
    }
    return profile;
  }

  async findByUserId(userId: string): Promise<VetProfile | null> {
    return this.vetProfileRepository.findOne({
      where: { userId },
    });
  }

  async create(input: CreateVetProfileInput, userId?: string): Promise<VetProfile> {
    const profile = this.vetProfileRepository.create({
      ...input,
      userId,
    });
    return this.vetProfileRepository.save(profile);
  }

  async update(id: string, input: UpdateVetProfileInput): Promise<VetProfile> {
    const profile = await this.findOne(id);
    Object.assign(profile, input);
    return this.vetProfileRepository.save(profile);
  }

  async remove(id: string): Promise<void> {
    const profile = await this.findOne(id);
    await this.vetProfileRepository.remove(profile);
  }

  async findVerified(): Promise<VetProfile[]> {
    return this.vetProfileRepository.find({
      where: { isActive: true, isVerified: true },
      order: { createdAt: 'DESC' },
    });
  }
}
