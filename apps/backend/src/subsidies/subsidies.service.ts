import { Injectable, NotFoundException, BadRequestException } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository, LessThan } from 'typeorm';
import { SubsidyRequest, SubsidyRequestStatus } from './entities/subsidy-request.entity';
import { JurisdictionsService } from '../jurisdictions/jurisdictions.service';
import { Animal } from '../animals/entities/animal.entity';

@Injectable()
export class SubsidiesService {
  constructor(
    @InjectRepository(SubsidyRequest)
    private readonly subsidyRepository: Repository<SubsidyRequest>,
    @InjectRepository(Animal)
    private readonly animalRepository: Repository<Animal>,
    private readonly jurisdictionsService: JurisdictionsService,
  ) {}

  async create(data: {
    animalId: string;
    requesterId: string;
    amountRequested: number;
    justification: string;
  }): Promise<SubsidyRequest> {
    // 1. Validate animal existence and location
    const animal = await this.animalRepository.findOne({ where: { id: data.animalId } });
    if (!animal) {
      throw new NotFoundException(`Animal with ID ${data.animalId} not found`);
    }

    if (!animal.location) {
        throw new BadRequestException('Animal must have a location to request a subsidy');
    }

    // 2. Find municipality by animal location
    const [longitude, latitude] = animal.location.coordinates;
    const jurisdiction = await this.jurisdictionsService.findByCoordinates(latitude, longitude);

    // 3. Create request
    const request = this.subsidyRepository.create({
      animalId: data.animalId,
      requesterId: data.requesterId,
      amountRequested: data.amountRequested,
      justification: data.justification,
      municipalityId: jurisdiction?.organizationId,
      status: SubsidyRequestStatus.CREATED,
      expiresAt: new Date(Date.now() + 72 * 60 * 60 * 1000), // 72 hours expiration
    });

    return this.subsidyRepository.save(request);
  }

  async findOne(id: string): Promise<SubsidyRequest> {
    const request = await this.subsidyRepository.findOne({
      where: { id },
      relations: ['animal', 'requester', 'municipality'],
    });
    if (!request) {
      throw new NotFoundException(`Subsidy request with ID ${id} not found`);
    }
    return request;
  }

  async findAllByRequester(requesterId: string): Promise<SubsidyRequest[]> {
    return this.subsidyRepository.find({
      where: { requesterId },
      order: { createdAt: 'DESC' },
    });
  }

  async updateStatus(id: string, status: SubsidyRequestStatus): Promise<SubsidyRequest> {
    const request = await this.findOne(id);
    request.status = status;
    return this.subsidyRepository.save(request);
  }

  async expireOldRequests(): Promise<number> {
    const result = await this.subsidyRepository.update(
      {
        status: SubsidyRequestStatus.CREATED,
        expiresAt: LessThan(new Date()),
      },
      { status: SubsidyRequestStatus.EXPIRED },
    );
    return result.affected || 0;
  }
}
