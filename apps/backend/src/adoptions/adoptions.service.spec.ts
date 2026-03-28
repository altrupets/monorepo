import { Test, TestingModule } from '@nestjs/testing';
import { getRepositoryToken } from '@nestjs/typeorm';
import { NotFoundException, BadRequestException, ForbiddenException } from '@nestjs/common';
import { AdoptionsService } from './adoptions.service';
import { AdoptionListing } from './entities/adoption-listing.entity';
import { Animal, AnimalStatus } from '../animals/entities/animal.entity';
import { ListingStatus } from './enums/listing-status.enum';

describe('AdoptionsService', () => {
  let service: AdoptionsService;
  let mockListingRepository: any;
  let mockAnimalRepository: any;

  const publisherId = 'user-uuid-1';
  const animalId = 'animal-uuid-1';
  const listingId = 'listing-uuid-1';

  const mockAnimal: Partial<Animal> = {
    id: animalId,
    name: 'Firulais',
    status: AnimalStatus.READY_FOR_ADOPTION,
    imageUrl: 'https://example.com/photo.jpg',
  };

  const mockListing: Partial<AdoptionListing> = {
    id: listingId,
    animalId,
    publisherId,
    status: ListingStatus.DRAFT,
    title: 'Adopt Firulais',
    description: 'Friendly dog looking for a home',
  };

  beforeEach(async () => {
    mockListingRepository = {
      create: jest.fn((data) => ({ ...data, id: listingId })),
      save: jest.fn((entity) => Promise.resolve({ ...entity })),
      findOne: jest.fn(),
      find: jest.fn(),
      createQueryBuilder: jest.fn(),
    };

    mockAnimalRepository = {
      findOne: jest.fn(),
    };

    const module: TestingModule = await Test.createTestingModule({
      providers: [
        AdoptionsService,
        {
          provide: getRepositoryToken(AdoptionListing),
          useValue: mockListingRepository,
        },
        {
          provide: getRepositoryToken(Animal),
          useValue: mockAnimalRepository,
        },
      ],
    }).compile();

    service = module.get<AdoptionsService>(AdoptionsService);
  });

  it('should be defined', () => {
    expect(service).toBeDefined();
  });

  describe('createListing', () => {
    it('should create a listing in DRAFT status', async () => {
      mockAnimalRepository.findOne.mockResolvedValue(mockAnimal);
      mockListingRepository.findOne.mockResolvedValue(null);

      const result = await service.createListing(
        {
          animalId,
          title: 'Adopt Firulais',
          description: 'Friendly dog',
        },
        publisherId,
      );

      expect(result.status).toBe(ListingStatus.DRAFT);
      expect(mockListingRepository.create).toHaveBeenCalledWith(
        expect.objectContaining({ status: ListingStatus.DRAFT }),
      );
    });

    it('should throw if animal not found', async () => {
      mockAnimalRepository.findOne.mockResolvedValue(null);

      await expect(
        service.createListing(
          { animalId: 'nonexistent', title: 'Test', description: 'Test' },
          publisherId,
        ),
      ).rejects.toThrow(NotFoundException);
    });

    it('should throw if listing already exists for animal', async () => {
      mockAnimalRepository.findOne.mockResolvedValue(mockAnimal);
      mockListingRepository.findOne.mockResolvedValue(mockListing);

      await expect(
        service.createListing(
          { animalId, title: 'Test', description: 'Test' },
          publisherId,
        ),
      ).rejects.toThrow(BadRequestException);
    });
  });

  describe('publishListing', () => {
    it('should transition DRAFT to ACTIVE', async () => {
      mockListingRepository.findOne.mockResolvedValue({ ...mockListing });
      mockAnimalRepository.findOne.mockResolvedValue(mockAnimal);

      const result = await service.publishListing(listingId, publisherId);

      expect(result.status).toBe(ListingStatus.ACTIVE);
      expect(result.publishedAt).toBeDefined();
    });

    it('should throw if animal has no photos', async () => {
      mockListingRepository.findOne.mockResolvedValue({ ...mockListing });
      mockAnimalRepository.findOne.mockResolvedValue({
        ...mockAnimal,
        imageUrl: null,
      });

      await expect(
        service.publishListing(listingId, publisherId),
      ).rejects.toThrow(BadRequestException);
    });

    it('should throw if animal is not READY_FOR_ADOPTION', async () => {
      mockListingRepository.findOne.mockResolvedValue({ ...mockListing });
      mockAnimalRepository.findOne.mockResolvedValue({
        ...mockAnimal,
        status: AnimalStatus.RESCUED,
      });

      await expect(
        service.publishListing(listingId, publisherId),
      ).rejects.toThrow(BadRequestException);
    });

    it('should throw if listing is not in DRAFT', async () => {
      mockListingRepository.findOne.mockResolvedValue({
        ...mockListing,
        status: ListingStatus.ACTIVE,
      });

      await expect(
        service.publishListing(listingId, publisherId),
      ).rejects.toThrow(BadRequestException);
    });

    it('should throw if user is not the publisher', async () => {
      mockListingRepository.findOne.mockResolvedValue({ ...mockListing });

      await expect(
        service.publishListing(listingId, 'other-user'),
      ).rejects.toThrow(ForbiddenException);
    });
  });

  describe('pauseListing', () => {
    it('should transition ACTIVE to PAUSED', async () => {
      mockListingRepository.findOne.mockResolvedValue({
        ...mockListing,
        status: ListingStatus.ACTIVE,
      });

      const result = await service.pauseListing(listingId, publisherId);
      expect(result.status).toBe(ListingStatus.PAUSED);
    });

    it('should throw if listing is not ACTIVE', async () => {
      mockListingRepository.findOne.mockResolvedValue({
        ...mockListing,
        status: ListingStatus.DRAFT,
      });

      await expect(
        service.pauseListing(listingId, publisherId),
      ).rejects.toThrow(BadRequestException);
    });
  });

  describe('reactivateListing', () => {
    it('should transition PAUSED to ACTIVE', async () => {
      mockListingRepository.findOne.mockResolvedValue({
        ...mockListing,
        status: ListingStatus.PAUSED,
      });

      const result = await service.reactivateListing(listingId, publisherId);
      expect(result.status).toBe(ListingStatus.ACTIVE);
    });

    it('should throw if listing is not PAUSED', async () => {
      mockListingRepository.findOne.mockResolvedValue({
        ...mockListing,
        status: ListingStatus.ACTIVE,
      });

      await expect(
        service.reactivateListing(listingId, publisherId),
      ).rejects.toThrow(BadRequestException);
    });
  });

  describe('closeListing', () => {
    it('should close ACTIVE listing as ADOPTED', async () => {
      mockListingRepository.findOne.mockResolvedValue({
        ...mockListing,
        status: ListingStatus.ACTIVE,
      });

      const result = await service.closeListing(
        listingId,
        publisherId,
        'ADOPTED',
      );

      expect(result.status).toBe(ListingStatus.ADOPTED);
      expect(result.closedAt).toBeDefined();
    });

    it('should close PAUSED listing as WITHDRAWN', async () => {
      mockListingRepository.findOne.mockResolvedValue({
        ...mockListing,
        status: ListingStatus.PAUSED,
      });

      const result = await service.closeListing(
        listingId,
        publisherId,
        'WITHDRAWN',
      );

      expect(result.status).toBe(ListingStatus.WITHDRAWN);
      expect(result.closedAt).toBeDefined();
    });

    it('should throw if listing is in DRAFT', async () => {
      mockListingRepository.findOne.mockResolvedValue({
        ...mockListing,
        status: ListingStatus.DRAFT,
      });

      await expect(
        service.closeListing(listingId, publisherId, 'WITHDRAWN'),
      ).rejects.toThrow(BadRequestException);
    });
  });

  describe('updateListing', () => {
    it('should update a DRAFT listing', async () => {
      mockListingRepository.findOne.mockResolvedValue({ ...mockListing });

      const result = await service.updateListing(listingId, publisherId, {
        title: 'Updated Title',
      });

      expect(result.title).toBe('Updated Title');
    });

    it('should update an ACTIVE listing', async () => {
      mockListingRepository.findOne.mockResolvedValue({
        ...mockListing,
        status: ListingStatus.ACTIVE,
      });

      const result = await service.updateListing(listingId, publisherId, {
        description: 'Updated description',
      });

      expect(result.description).toBe('Updated description');
    });

    it('should throw if listing is ADOPTED', async () => {
      mockListingRepository.findOne.mockResolvedValue({
        ...mockListing,
        status: ListingStatus.ADOPTED,
      });

      await expect(
        service.updateListing(listingId, publisherId, { title: 'Test' }),
      ).rejects.toThrow(BadRequestException);
    });
  });
});
