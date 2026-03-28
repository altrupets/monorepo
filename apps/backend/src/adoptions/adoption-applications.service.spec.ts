import { Test, TestingModule } from '@nestjs/testing';
import { getRepositoryToken } from '@nestjs/typeorm';
import { NotFoundException, BadRequestException } from '@nestjs/common';
import { AdoptionApplicationsService } from './adoption-applications.service';
import { AdoptionApplication } from './entities/adoption-application.entity';
import { AdoptionListing } from './entities/adoption-listing.entity';
import { ApplicationStatus } from './enums/application-status.enum';
import { ListingStatus } from './enums/listing-status.enum';
import { NotificationsService } from '../notifications/notifications.service';

describe('AdoptionApplicationsService', () => {
  let service: AdoptionApplicationsService;
  let mockApplicationRepository: any;
  let mockListingRepository: any;
  let mockNotificationsService: any;

  const applicantUserId = 'user-uuid-1';
  const reviewerUserId = 'user-uuid-2';
  const publisherUserId = 'user-uuid-3';
  const listingId = 'listing-uuid-1';
  const applicationId = 'application-uuid-1';

  const mockListing: Partial<AdoptionListing> = {
    id: listingId,
    animalId: 'animal-uuid-1',
    publisherId: publisherUserId,
    status: ListingStatus.ACTIVE,
    title: 'Adopt Firulais',
    description: 'Friendly dog',
  };

  const mockApplication: Partial<AdoptionApplication> = {
    id: applicationId,
    listingId,
    applicantUserId,
    status: ApplicationStatus.SUBMITTED,
    homeDescription: 'A house with a garden',
    familyDescription: 'Family of 4',
    petExperience: '5 years with dogs',
    contactPhone: '+506 8888-8888',
    motivation: 'We love animals',
  };

  beforeEach(async () => {
    mockApplicationRepository = {
      create: jest.fn((data) => ({ ...data, id: applicationId })),
      save: jest.fn((entity) => Promise.resolve({ ...entity })),
      findOne: jest.fn(),
      find: jest.fn(),
      count: jest.fn(),
    };

    mockListingRepository = {
      findOne: jest.fn(),
      save: jest.fn((entity) => Promise.resolve({ ...entity })),
    };

    mockNotificationsService = {
      sendToUser: jest.fn().mockResolvedValue({}),
    };

    const module: TestingModule = await Test.createTestingModule({
      providers: [
        AdoptionApplicationsService,
        {
          provide: getRepositoryToken(AdoptionApplication),
          useValue: mockApplicationRepository,
        },
        {
          provide: getRepositoryToken(AdoptionListing),
          useValue: mockListingRepository,
        },
        {
          provide: NotificationsService,
          useValue: mockNotificationsService,
        },
      ],
    }).compile();

    service = module.get<AdoptionApplicationsService>(
      AdoptionApplicationsService,
    );
  });

  it('should be defined', () => {
    expect(service).toBeDefined();
  });

  describe('submit', () => {
    it('should create a new application in SUBMITTED status', async () => {
      mockListingRepository.findOne.mockResolvedValue(mockListing);
      mockApplicationRepository.findOne.mockResolvedValue(null);
      mockApplicationRepository.count.mockResolvedValue(0);

      const result = await service.submit(
        {
          listingId,
          homeDescription: 'A house with a garden',
          familyDescription: 'Family of 4',
          petExperience: '5 years with dogs',
          contactPhone: '+506 8888-8888',
          motivation: 'We love animals',
        },
        applicantUserId,
      );

      expect(result.status).toBe(ApplicationStatus.SUBMITTED);
      expect(mockNotificationsService.sendToUser).toHaveBeenCalled();
    });

    it('should throw if listing is not ACTIVE', async () => {
      mockListingRepository.findOne.mockResolvedValue({
        ...mockListing,
        status: ListingStatus.PAUSED,
      });

      await expect(
        service.submit(
          {
            listingId,
            homeDescription: 'Test',
            familyDescription: 'Test',
            petExperience: 'Test',
            contactPhone: '1234',
            motivation: 'Test',
          },
          applicantUserId,
        ),
      ).rejects.toThrow(BadRequestException);
    });

    it('should throw if applicant already applied to this listing', async () => {
      mockListingRepository.findOne.mockResolvedValue(mockListing);
      mockApplicationRepository.findOne.mockResolvedValue(mockApplication);

      await expect(
        service.submit(
          {
            listingId,
            homeDescription: 'Test',
            familyDescription: 'Test',
            petExperience: 'Test',
            contactPhone: '1234',
            motivation: 'Test',
          },
          applicantUserId,
        ),
      ).rejects.toThrow(BadRequestException);
    });

    it('should throw if applicant has 3 active applications', async () => {
      mockListingRepository.findOne.mockResolvedValue(mockListing);
      mockApplicationRepository.findOne.mockResolvedValue(null);
      mockApplicationRepository.count.mockResolvedValue(3);

      await expect(
        service.submit(
          {
            listingId,
            homeDescription: 'Test',
            familyDescription: 'Test',
            petExperience: 'Test',
            contactPhone: '1234',
            motivation: 'Test',
          },
          applicantUserId,
        ),
      ).rejects.toThrow(BadRequestException);
    });

    it('should throw if listing not found', async () => {
      mockListingRepository.findOne.mockResolvedValue(null);

      await expect(
        service.submit(
          {
            listingId: 'nonexistent',
            homeDescription: 'Test',
            familyDescription: 'Test',
            petExperience: 'Test',
            contactPhone: '1234',
            motivation: 'Test',
          },
          applicantUserId,
        ),
      ).rejects.toThrow(NotFoundException);
    });
  });

  describe('transition validations', () => {
    it('should transition SUBMITTED to IN_REVIEW', async () => {
      mockApplicationRepository.findOne.mockResolvedValue({
        ...mockApplication,
      });

      const result = await service.review(applicationId, reviewerUserId);
      expect(result.status).toBe(ApplicationStatus.IN_REVIEW);
    });

    it('should not allow SUBMITTED to VISIT_SCHEDULED', async () => {
      mockApplicationRepository.findOne.mockResolvedValue({
        ...mockApplication,
      });

      await expect(
        service.scheduleVisit(applicationId, reviewerUserId, new Date()),
      ).rejects.toThrow(BadRequestException);
    });

    it('should transition IN_REVIEW to VISIT_SCHEDULED', async () => {
      mockApplicationRepository.findOne.mockResolvedValue({
        ...mockApplication,
        status: ApplicationStatus.IN_REVIEW,
      });

      const scheduledDate = new Date('2026-04-15');
      const result = await service.scheduleVisit(
        applicationId,
        reviewerUserId,
        scheduledDate,
      );

      expect(result.status).toBe(ApplicationStatus.VISIT_SCHEDULED);
      expect(result.visitScheduledAt).toBe(scheduledDate);
    });

    it('should transition VISIT_SCHEDULED to VISIT_COMPLETED', async () => {
      mockApplicationRepository.findOne.mockResolvedValue({
        ...mockApplication,
        status: ApplicationStatus.VISIT_SCHEDULED,
      });

      const result = await service.completeVisit(
        applicationId,
        reviewerUserId,
        'Everything looks great',
      );

      expect(result.status).toBe(ApplicationStatus.VISIT_COMPLETED);
      expect(result.visitNotes).toBe('Everything looks great');
    });

    it('should not allow SUBMITTED to APPROVED', async () => {
      mockApplicationRepository.findOne.mockResolvedValue({
        ...mockApplication,
      });

      await expect(
        service.approve(applicationId, reviewerUserId),
      ).rejects.toThrow(BadRequestException);
    });

    it('should reject from any non-terminal status', async () => {
      for (const status of [
        ApplicationStatus.SUBMITTED,
        ApplicationStatus.IN_REVIEW,
        ApplicationStatus.VISIT_SCHEDULED,
        ApplicationStatus.VISIT_COMPLETED,
      ]) {
        mockApplicationRepository.findOne.mockResolvedValue({
          ...mockApplication,
          status,
        });

        const result = await service.reject(
          applicationId,
          reviewerUserId,
          'Not suitable',
        );

        expect(result.status).toBe(ApplicationStatus.REJECTED);
      }
    });

    it('should not allow transition from APPROVED', async () => {
      mockApplicationRepository.findOne.mockResolvedValue({
        ...mockApplication,
        status: ApplicationStatus.APPROVED,
      });

      await expect(
        service.reject(applicationId, reviewerUserId, 'Changed mind'),
      ).rejects.toThrow(BadRequestException);
    });

    it('should not allow transition from REJECTED', async () => {
      mockApplicationRepository.findOne.mockResolvedValue({
        ...mockApplication,
        status: ApplicationStatus.REJECTED,
      });

      await expect(
        service.review(applicationId, reviewerUserId),
      ).rejects.toThrow(BadRequestException);
    });
  });

  describe('approve cascades', () => {
    it('should close listing as ADOPTED and reject other applications', async () => {
      const otherApp = {
        id: 'other-app-uuid',
        listingId,
        applicantUserId: 'other-user',
        status: ApplicationStatus.IN_REVIEW,
      };

      mockApplicationRepository.findOne.mockResolvedValue({
        ...mockApplication,
        status: ApplicationStatus.VISIT_COMPLETED,
      });
      mockListingRepository.findOne.mockResolvedValue({ ...mockListing });
      mockApplicationRepository.find.mockResolvedValue([otherApp]);

      await service.approve(applicationId, reviewerUserId);

      // Verify listing was closed as ADOPTED
      expect(mockListingRepository.save).toHaveBeenCalledWith(
        expect.objectContaining({
          status: ListingStatus.ADOPTED,
          closedAt: expect.any(Date),
        }),
      );

      // Verify other applications were rejected
      expect(mockApplicationRepository.save).toHaveBeenCalledWith(
        expect.objectContaining({
          id: 'other-app-uuid',
          status: ApplicationStatus.REJECTED,
        }),
      );

      // Verify notifications sent
      expect(mockNotificationsService.sendToUser).toHaveBeenCalled();
    });
  });
});
