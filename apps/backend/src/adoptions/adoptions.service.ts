import {
  Injectable,
  NotFoundException,
  BadRequestException,
  ForbiddenException,
} from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { AdoptionListing } from './entities/adoption-listing.entity';
import { ListingStatus } from './enums/listing-status.enum';
import { Animal, AnimalStatus } from '../animals/entities/animal.entity';
import { CreateAdoptionListingInput } from './dto/create-adoption-listing.input';
import { UpdateAdoptionListingInput } from './dto/update-adoption-listing.input';
import { AdoptionListingFilterInput } from './dto/adoption-listing-filter.input';

@Injectable()
export class AdoptionsService {
  constructor(
    @InjectRepository(AdoptionListing)
    private readonly listingRepository: Repository<AdoptionListing>,
    @InjectRepository(Animal)
    private readonly animalRepository: Repository<Animal>,
  ) {}

  async createListing(
    input: CreateAdoptionListingInput,
    publisherId: string,
  ): Promise<AdoptionListing> {
    const animal = await this.animalRepository.findOne({
      where: { id: input.animalId },
    });
    if (!animal) {
      throw new NotFoundException(`Animal with ID ${input.animalId} not found`);
    }

    const existingListing = await this.listingRepository.findOne({
      where: { animalId: input.animalId },
    });
    if (existingListing) {
      throw new BadRequestException(
        'A listing already exists for this animal',
      );
    }

    const listing = this.listingRepository.create({
      ...input,
      publisherId,
      status: ListingStatus.DRAFT,
    });

    return this.listingRepository.save(listing);
  }

  async publishListing(
    listingId: string,
    publisherId: string,
  ): Promise<AdoptionListing> {
    const listing = await this.findByIdAndValidateOwner(listingId, publisherId);

    if (listing.status !== ListingStatus.DRAFT) {
      throw new BadRequestException(
        `Cannot publish listing in status ${listing.status}. Only DRAFT listings can be published.`,
      );
    }

    const animal = await this.animalRepository.findOne({
      where: { id: listing.animalId },
    });
    if (!animal) {
      throw new NotFoundException('Animal not found for this listing');
    }

    if (animal.status !== AnimalStatus.READY_FOR_ADOPTION) {
      throw new BadRequestException(
        'Animal must have status READY_FOR_ADOPTION before publishing the listing',
      );
    }

    if (!animal.imageUrl) {
      throw new BadRequestException(
        'Animal must have at least one photo before publishing the listing',
      );
    }

    listing.status = ListingStatus.ACTIVE;
    listing.publishedAt = new Date();

    return this.listingRepository.save(listing);
  }

  async pauseListing(
    listingId: string,
    publisherId: string,
  ): Promise<AdoptionListing> {
    const listing = await this.findByIdAndValidateOwner(listingId, publisherId);

    if (listing.status !== ListingStatus.ACTIVE) {
      throw new BadRequestException(
        `Cannot pause listing in status ${listing.status}. Only ACTIVE listings can be paused.`,
      );
    }

    listing.status = ListingStatus.PAUSED;
    return this.listingRepository.save(listing);
  }

  async reactivateListing(
    listingId: string,
    publisherId: string,
  ): Promise<AdoptionListing> {
    const listing = await this.findByIdAndValidateOwner(listingId, publisherId);

    if (listing.status !== ListingStatus.PAUSED) {
      throw new BadRequestException(
        `Cannot reactivate listing in status ${listing.status}. Only PAUSED listings can be reactivated.`,
      );
    }

    listing.status = ListingStatus.ACTIVE;
    return this.listingRepository.save(listing);
  }

  async closeListing(
    listingId: string,
    publisherId: string,
    reason: 'ADOPTED' | 'WITHDRAWN',
  ): Promise<AdoptionListing> {
    const listing = await this.findByIdAndValidateOwner(listingId, publisherId);

    if (
      listing.status !== ListingStatus.ACTIVE &&
      listing.status !== ListingStatus.PAUSED
    ) {
      throw new BadRequestException(
        `Cannot close listing in status ${listing.status}. Only ACTIVE or PAUSED listings can be closed.`,
      );
    }

    listing.status =
      reason === 'ADOPTED' ? ListingStatus.ADOPTED : ListingStatus.WITHDRAWN;
    listing.closedAt = new Date();

    return this.listingRepository.save(listing);
  }

  async updateListing(
    listingId: string,
    publisherId: string,
    input: UpdateAdoptionListingInput,
  ): Promise<AdoptionListing> {
    const listing = await this.findByIdAndValidateOwner(listingId, publisherId);

    if (
      listing.status !== ListingStatus.DRAFT &&
      listing.status !== ListingStatus.ACTIVE
    ) {
      throw new BadRequestException(
        `Cannot update listing in status ${listing.status}. Only DRAFT or ACTIVE listings can be updated.`,
      );
    }

    Object.assign(listing, input);
    return this.listingRepository.save(listing);
  }

  async findListings(
    filter?: AdoptionListingFilterInput,
    first?: number,
    after?: string,
  ): Promise<AdoptionListing[]> {
    const take = first ?? 20;

    const qb = this.listingRepository
      .createQueryBuilder('listing')
      .leftJoinAndSelect('listing.animal', 'animal')
      .leftJoinAndSelect('listing.publisher', 'publisher')
      .where('listing.status = :status', { status: ListingStatus.ACTIVE });

    if (filter) {
      if (filter.species) {
        qb.andWhere('animal.species = :species', { species: filter.species });
      }
      if (filter.size) {
        qb.andWhere('animal.size = :size', { size: filter.size });
      }
      if (filter.ageCategory) {
        qb.andWhere('animal.ageCategory = :ageCategory', {
          ageCategory: filter.ageCategory,
        });
      }
      if (filter.isChildFriendly !== undefined) {
        qb.andWhere('listing.isChildFriendly = :isChildFriendly', {
          isChildFriendly: filter.isChildFriendly,
        });
      }
      if (filter.isPetFriendly !== undefined) {
        qb.andWhere('listing.isPetFriendly = :isPetFriendly', {
          isPetFriendly: filter.isPetFriendly,
        });
      }
      if (filter.isSterilized !== undefined) {
        qb.andWhere('animal.isSterilized = :isSterilized', {
          isSterilized: filter.isSterilized,
        });
      }
    }

    if (after) {
      qb.andWhere('listing.id > :after', { after });
    }

    qb.orderBy('listing.publishedAt', 'DESC').take(take);

    return qb.getMany();
  }

  async findById(id: string): Promise<AdoptionListing> {
    const listing = await this.listingRepository.findOne({
      where: { id },
      relations: ['animal', 'publisher'],
    });
    if (!listing) {
      throw new NotFoundException(`Adoption listing with ID ${id} not found`);
    }
    return listing;
  }

  async findMyListings(
    publisherId: string,
    status?: ListingStatus,
  ): Promise<AdoptionListing[]> {
    const where: Record<string, unknown> = { publisherId };
    if (status) {
      where.status = status;
    }

    return this.listingRepository.find({
      where,
      relations: ['animal'],
      order: { createdAt: 'DESC' },
    });
  }

  private async findByIdAndValidateOwner(
    listingId: string,
    publisherId: string,
  ): Promise<AdoptionListing> {
    const listing = await this.listingRepository.findOne({
      where: { id: listingId },
    });
    if (!listing) {
      throw new NotFoundException(
        `Adoption listing with ID ${listingId} not found`,
      );
    }
    if (listing.publisherId !== publisherId) {
      throw new ForbiddenException(
        'You can only manage your own adoption listings',
      );
    }
    return listing;
  }
}
