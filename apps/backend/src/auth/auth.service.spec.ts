import { Test, TestingModule } from '@nestjs/testing';
import { AuthService } from './auth.service';
import { JwtService } from '@nestjs/jwt';
import { ConfigService } from '@nestjs/config';
import { getRepositoryToken } from '@nestjs/typeorm';
import { User } from '../users/entities/user.entity';
import { UserRole } from './roles/user-role.enum';
import { BadRequestException, UnauthorizedException } from '@nestjs/common';
import { Cache } from 'cache-manager';
import { createHash } from 'crypto';
import { MailService } from '../mail/mail.service';

describe('AuthService', () => {
  let service: AuthService;
  let mockUserRepository: any;
  let mockJwtService: any;
  let mockCacheManager: any;
  let mockMailService: any;
  let mockConfigService: any;

  const PASSWORD_SALT = 'test-salt-for-testing';

  const hashPassword = (password: string, username: string): string => {
    const firstHash = createHash('sha256').update(password).digest('hex');
    const combined = firstHash + PASSWORD_SALT + username.toLowerCase();
    return createHash('sha256').update(combined).digest('hex');
  };

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

    mockMailService = {
      sendVerificationEmail: jest.fn().mockResolvedValue(undefined),
      sendPasswordResetEmail: jest.fn().mockResolvedValue(undefined),
    };

    mockConfigService = {
      get: jest.fn((key: string, defaultValue?: any) => {
        const config: Record<string, any> = {
          JWT_SECRET: 'test-secret-key',
          PASSWORD_SALT: 'test-salt',
          ACCESS_TOKEN_EXPIRY: '1h',
          REFRESH_TOKEN_EXPIRY: '7d',
          APP_URL: 'http://localhost:3000',
          EMAIL_VERIFICATION_TTL: 86400,
          PASSWORD_RESET_TTL: 3600,
        };
        return config[key] ?? defaultValue;
      }),
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
        {
          provide: MailService,
          useValue: mockMailService,
        },
        {
          provide: ConfigService,
          useValue: mockConfigService,
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
        passwordHash: hashPassword('password123', 'testuser'),
      });

      const result = await service.validateUser('testuser', 'password123');

      expect(result).toBeDefined();
      expect(result.username).toBe('testuser');
      expect(result.passwordHash).toBeUndefined();
    });

    it('should throw error when user not found', async () => {
      mockUserRepository.findByUsername.mockResolvedValue(null);

      await expect(
        service.validateUser('nonexistent', 'password'),
      ).rejects.toThrow('USER_NOT_FOUND');
    });

    it('should throw error when password is invalid', async () => {
      mockUserRepository.findByUsername.mockResolvedValue({
        ...mockUser,
        passwordHash: hashPassword('correctpassword', 'testuser'),
      });

      await expect(
        service.validateUser('testuser', 'wrongpassword'),
      ).rejects.toThrow('INVALID_PASSWORD');
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
      await service.logout(mockUser.id!, 'refresh-token');

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

  describe('sendVerificationEmail', () => {
    it('should store token in cache and send email', async () => {
      mockUserRepository.findById.mockResolvedValue({
        ...mockUser,
        email: 'test@example.com',
      });

      const result = await service.sendVerificationEmail(mockUser.id!);

      expect(result).toBe(true);
      expect(mockCacheManager.set).toHaveBeenCalledWith(
        expect.stringMatching(/^verify:/),
        mockUser.id,
        86400000, // 86400 * 1000
      );
      // Mail is fire-and-forget so we wait a tick for the promise chain
      await new Promise((r) => setTimeout(r, 10));
      expect(mockMailService.sendVerificationEmail).toHaveBeenCalledWith(
        'test@example.com',
        mockUser.username,
        expect.any(String),
        'http://localhost:3000',
      );
    });

    it('should return false when user has no email', async () => {
      mockUserRepository.findById.mockResolvedValue({
        ...mockUser,
        email: undefined,
      });

      const result = await service.sendVerificationEmail(mockUser.id!);
      expect(result).toBe(false);
    });

    it('should return false when user not found', async () => {
      mockUserRepository.findById.mockResolvedValue(null);

      const result = await service.sendVerificationEmail('non-existent-id');
      expect(result).toBe(false);
    });
  });

  describe('verifyEmailToken', () => {
    it('should validate token and update user isVerified', async () => {
      const userToVerify = { ...mockUser, isVerified: false };
      mockCacheManager.get.mockResolvedValue(mockUser.id);
      mockUserRepository.findById.mockResolvedValue(userToVerify);
      mockUserRepository.save.mockResolvedValue({
        ...userToVerify,
        isVerified: true,
      });

      const result = await service.verifyEmailToken('valid-token');

      expect(result).toBe(true);
      expect(mockUserRepository.save).toHaveBeenCalledWith(
        expect.objectContaining({ isVerified: true }),
      );
      expect(mockCacheManager.del).toHaveBeenCalledWith('verify:valid-token');
    });

    it('should throw BadRequestException for invalid token', async () => {
      mockCacheManager.get.mockResolvedValue(null);

      await expect(
        service.verifyEmailToken('invalid-token'),
      ).rejects.toThrow(BadRequestException);
    });
  });

  describe('requestPasswordReset', () => {
    it('should return true even when email does not exist', async () => {
      mockUserRepository.findByEmail.mockResolvedValue(null);

      const result = await service.requestPasswordReset('nonexistent@example.com');

      expect(result).toBe(true);
      expect(mockCacheManager.set).not.toHaveBeenCalled();
    });

    it('should store reset token in cache when user exists', async () => {
      mockUserRepository.findByEmail.mockResolvedValue({
        ...mockUser,
        email: 'test@example.com',
      });

      const result = await service.requestPasswordReset('test@example.com');

      expect(result).toBe(true);
      expect(mockCacheManager.set).toHaveBeenCalledWith(
        expect.stringMatching(/^reset:/),
        mockUser.id,
        3600000, // 3600 * 1000
      );
    });
  });

  describe('resetPasswordWithToken', () => {
    it('should validate token and update password hash', async () => {
      const userToReset = { ...mockUser, passwordHash: 'old-hash' };
      mockCacheManager.get.mockResolvedValue(mockUser.id);
      mockUserRepository.findById.mockResolvedValue(userToReset);
      mockUserRepository.save.mockResolvedValue(userToReset);

      const result = await service.resetPasswordWithToken(
        'valid-reset-token',
        'newPassword123',
      );

      expect(result).toBe(true);
      expect(mockUserRepository.save).toHaveBeenCalledWith(
        expect.objectContaining({
          passwordHash: expect.not.stringMatching(/^old-hash$/),
        }),
      );
      expect(mockCacheManager.del).toHaveBeenCalledWith(
        'reset:valid-reset-token',
      );
    });

    it('should throw BadRequestException for invalid token', async () => {
      mockCacheManager.get.mockResolvedValue(null);

      await expect(
        service.resetPasswordWithToken('invalid-token', 'newPassword'),
      ).rejects.toThrow(BadRequestException);
    });
  });
});
