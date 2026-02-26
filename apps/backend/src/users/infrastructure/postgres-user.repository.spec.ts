import { Test, TestingModule } from '@nestjs/testing';
import { getRepositoryToken } from '@nestjs/typeorm';
import { User } from '../entities/user.entity';
import { PostgresUserRepository } from '../infrastructure/postgres-user.repository';
import { UserRole } from '../../auth/roles/user-role.enum';

describe('PostgresUserRepository', () => {
  let repository: PostgresUserRepository;
  let mockRepository: any;

  const mockUser: User = {
    id: '123e4567-e89b-12d3-a456-426614174000',
    username: 'testuser',
    email: 'test@example.com',
    passwordHash: 'hashedpassword',
    roles: [UserRole.WATCHER],
    firstName: 'Test',
    lastName: 'User',
    isActive: true,
    isVerified: false,
    createdAt: new Date(),
    updatedAt: new Date(),
  };

  beforeEach(async () => {
    mockRepository = {
      findOne: jest.fn(),
      find: jest.fn(),
      create: jest.fn(),
      save: jest.fn(),
      delete: jest.fn(),
      createQueryBuilder: jest.fn(() => ({
        where: jest.fn().mockReturnThis(),
        andWhere: jest.fn().mockReturnThis(),
        orderBy: jest.fn().mockReturnThis(),
        skip: jest.fn().mockReturnThis(),
        take: jest.fn().mockReturnThis(),
        getMany: jest.fn().mockResolvedValue([mockUser]),
        getOne: jest.fn().mockResolvedValue(mockUser),
      })),
    };

    const module: TestingModule = await Test.createTestingModule({
      providers: [
        PostgresUserRepository,
        {
          provide: getRepositoryToken(User),
          useValue: mockRepository,
        },
      ],
    }).compile();

    repository = module.get<PostgresUserRepository>(PostgresUserRepository);
  });

  it('should be defined', () => {
    expect(repository).toBeDefined();
  });

  describe('findAll', () => {
    it('should return array of users', async () => {
      mockRepository.find.mockResolvedValue([mockUser]);

      const result = await repository.findAll();

      expect(result).toEqual([mockUser]);
      expect(mockRepository.find).toHaveBeenCalledWith({
        order: { updatedAt: 'DESC' },
      });
    });

    it('should return empty array when no users', async () => {
      mockRepository.find.mockResolvedValue([]);

      const result = await repository.findAll();

      expect(result).toEqual([]);
    });
  });

  describe('findById', () => {
    it('should return user by id', async () => {
      mockRepository.findOne.mockResolvedValue(mockUser);

      const result = await repository.findById(mockUser.id);

      expect(result).toEqual(mockUser);
      expect(mockRepository.findOne).toHaveBeenCalledWith({
        where: { id: mockUser.id },
      });
    });

    it('should return null when user not found', async () => {
      mockRepository.findOne.mockResolvedValue(null);

      const result = await repository.findById('nonexistent-id');

      expect(result).toBeNull();
    });
  });

  describe('findByUsername', () => {
    it('should return user by username', async () => {
      mockRepository.findOne.mockResolvedValue(mockUser);

      const result = await repository.findByUsername('testuser');

      expect(result).toEqual(mockUser);
    });

    it('should return null when username not found', async () => {
      mockRepository.findOne.mockResolvedValue(null);

      const result = await repository.findByUsername('nonexistent');

      expect(result).toBeNull();
    });
  });

  describe('findByEmail', () => {
    it('should return user by email', async () => {
      mockRepository.findOne.mockResolvedValue(mockUser);

      const result = await repository.findByEmail('test@example.com');

      expect(result).toEqual(mockUser);
    });

    it('should return null when email not found', async () => {
      mockRepository.findOne.mockResolvedValue(null);

      const result = await repository.findByEmail('nonexistent@example.com');

      expect(result).toBeNull();
    });
  });

  describe('save', () => {
    it('should save user', async () => {
      mockRepository.create.mockReturnValue(mockUser);
      mockRepository.save.mockResolvedValue(mockUser);

      const result = await repository.save(mockUser);

      expect(result).toEqual(mockUser);
      expect(mockRepository.create).toHaveBeenCalledWith(mockUser);
      expect(mockRepository.save).toHaveBeenCalledWith(mockUser);
    });
  });

  describe('delete', () => {
    it('should delete user', async () => {
      mockRepository.delete.mockResolvedValue({ affected: 1, raw: [] });

      await repository.delete(mockUser.id);

      expect(mockRepository.delete).toHaveBeenCalledWith(mockUser.id);
    });
  });
});
