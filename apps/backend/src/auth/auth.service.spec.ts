import { Test, TestingModule } from '@nestjs/testing';
import { AuthService } from './auth.service';
import { JwtService } from '@nestjs/jwt';
import { getRepositoryToken } from '@nestjs/typeorm';
import { User } from '../users/entities/user.entity';
import { UserRole } from './roles/user-role.enum';
import { UnauthorizedException } from '@nestjs/common';
import { Cache } from 'cache-manager';
import * as bcrypt from 'bcrypt';

describe('AuthService', () => {
  let service: AuthService;
  let mockUserRepository: any;
  let mockJwtService: any;
  let mockCacheManager: any;

  const mockUser: Partial<User> = {
    id: '123e4567-e89b-12d3-a456-426614174000',
    username: 'testuser',
    passwordHash: 'hashedpassword',
    roles: [UserRole.WATCHER],
    email: 'test@example.com',
    isActive: true,
  };

  beforeEach(async () => {
    mockUserRepository = {
      findByUsername: jest.fn(),
      findById: jest.fn(),
      findByEmail: jest.fn(),
      save: jest.fn(),
    };

    mockJwtService = {
      sign: jest.fn().mockReturnValue('mock-jwt-token'),
      verify: jest.fn().mockReturnValue({
        sub: mockUser.id,
        username: mockUser.username,
        roles: mockUser.roles,
      }),
    };

    mockCacheManager = {
      get: jest.fn(),
      set: jest.fn(),
      del: jest.fn(),
    };

    const module: TestingModule = await Test.createTestingModule({
      providers: [
        AuthService,
        {
          provide: 'IUserRepository',
          useValue: mockUserRepository,
        },
        {
          provide: JwtService,
          useValue: mockJwtService,
        },
        {
          provide: 'CACHE_MANAGER',
          useValue: mockCacheManager,
        },
      ],
    }).compile();

    service = module.get<AuthService>(AuthService);
  });

  it('should be defined', () => {
    expect(service).toBeDefined();
  });

  describe('validateUser', () => {
    it('should return user without password when credentials are valid', async () => {
      mockUserRepository.findByUsername.mockResolvedValue({
        ...mockUser,
        passwordHash: await bcrypt.hash('password123', 12),
      });

      const result = await service.validateUser('testuser', 'password123');

      expect(result).toBeDefined();
      expect(result.username).toBe('testuser');
      expect(result.passwordHash).toBeUndefined();
    });

    it('should return null when user not found', async () => {
      mockUserRepository.findByUsername.mockResolvedValue(null);

      const result = await service.validateUser('nonexistent', 'password');

      expect(result).toBeNull();
    });

    it('should return null when password is invalid', async () => {
      mockUserRepository.findByUsername.mockResolvedValue({
        ...mockUser,
        passwordHash: await bcrypt.hash('correctpassword', 12),
      });

      const result = await service.validateUser('testuser', 'wrongpassword');

      expect(result).toBeNull();
    });
  });

  describe('login', () => {
    it('should return access and refresh tokens', async () => {
      const tokens = await service.login({
        id: mockUser.id,
        username: mockUser.username,
        roles: mockUser.roles,
      });

      expect(tokens.access_token).toBeDefined();
      expect(tokens.refresh_token).toBeDefined();
      expect(tokens.expires_in).toBe(3600);
      expect(mockJwtService.sign).toHaveBeenCalled();
      expect(mockCacheManager.set).toHaveBeenCalledTimes(2);
    });

    it('should throw error when user data is invalid', async () => {
      await expect(
        service.login({ id: '', username: '', roles: [] }),
      ).rejects.toThrow('Invalid user data for login');
    });
  });

  describe('refreshToken', () => {
    it('should return new tokens when refresh token is valid', async () => {
      mockCacheManager.get.mockResolvedValue(mockUser.id);
      mockUserRepository.findById.mockResolvedValue(mockUser);

      const tokens = await service.refreshToken('valid-refresh-token');

      expect(tokens.access_token).toBeDefined();
      expect(tokens.refresh_token).toBeDefined();
      expect(mockCacheManager.del).toHaveBeenCalled();
    });

    it('should throw UnauthorizedException when refresh token is invalid', async () => {
      mockCacheManager.get.mockResolvedValue(null);

      await expect(
        service.refreshToken('invalid-refresh-token'),
      ).rejects.toThrow(UnauthorizedException);
    });
  });

  describe('logout', () => {
    it('should invalidate tokens', async () => {
      await service.logout(mockUser.id, 'refresh-token');

      expect(mockCacheManager.del).toHaveBeenCalledTimes(2);
    });
  });

  describe('register', () => {
    it('should create a new user', async () => {
      mockUserRepository.findByUsername.mockResolvedValue(null);
      mockUserRepository.findByEmail.mockResolvedValue(null);
      mockUserRepository.save.mockResolvedValue({ ...mockUser, id: 'new-id' });

      const result = await service.register({
        username: 'newuser',
        password: 'password123',
        email: 'new@example.com',
      });

      expect(result).toBeDefined();
      expect(mockUserRepository.save).toHaveBeenCalled();
    });

    it('should throw error when username exists', async () => {
      mockUserRepository.findByUsername.mockResolvedValue(mockUser);

      await expect(
        service.register({
          username: 'testuser',
          password: 'password123',
        }),
      ).rejects.toThrow('Username already exists');
    });
  });

  describe('validateToken', () => {
    it('should return user payload for valid token', async () => {
      const result = await service.validateToken('valid-token');

      expect(result).toEqual({
        id: mockUser.id,
        username: mockUser.username,
        roles: mockUser.roles,
      });
    });

    it('should throw error for invalid token', async () => {
      mockJwtService.verify.mockImplementation(() => {
        throw new Error('Invalid token');
      });

      await expect(
        service.validateToken('invalid-token'),
      ).rejects.toThrow('Invalid token');
    });
  });
});
