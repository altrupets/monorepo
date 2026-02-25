import { Injectable, Inject, UnauthorizedException } from '@nestjs/common';
import { UserRole } from './roles/user-role.enum';
import { JwtService } from '@nestjs/jwt';
import * as bcrypt from 'bcrypt';
import { CACHE_MANAGER } from '@nestjs/cache-manager';
import type { Cache } from 'cache-manager';
import { IUSER_REPOSITORY } from '../users/domain/user.repository.interface';
import type { IUserRepository } from '../users/domain/user.repository.interface';
import { User } from '../users/entities/user.entity';
import { randomBytes } from 'crypto';

@Injectable()
export class AuthService {
  // Token expiration times
  private readonly ACCESS_TOKEN_EXPIRY = '1h'; // 1 hour
  private readonly REFRESH_TOKEN_EXPIRY = '7d'; // 7 days
  private readonly REFRESH_TOKEN_CACHE_TTL = 7 * 24 * 60 * 60 * 1000; // 7 days in ms

  constructor(
    @Inject(IUSER_REPOSITORY)
    private readonly userRepository: IUserRepository,
    private readonly jwtService: JwtService,
    @Inject(CACHE_MANAGER)
    private readonly cacheManager: Cache,
  ) {}

  async validateUser(
    username: string,
    pass: string,
  ): Promise<Partial<User> | null> {
    const user = await this.userRepository.findByUsername(username);
    if (user && (await bcrypt.compare(pass, user.passwordHash))) {
      const result: Record<string, unknown> = { ...user };
      delete result.passwordHash;
      return result as Partial<User>;
    }
    return null;
  }

  async login(user: Partial<User>) {
    if (!user.id || !user.username || !user.roles) {
      throw new Error('Invalid user data for login');
    }

    const payload = {
      username: user.username,
      sub: user.id,
      roles: user.roles,
    };

    // Generate access token (short-lived)
    const accessToken = this.jwtService.sign(payload, {
      expiresIn: this.ACCESS_TOKEN_EXPIRY,
    });

    // Generate refresh token (long-lived, random string)
    const refreshToken = this.generateRefreshToken();

    // Store refresh token in cache with user ID mapping
    await this.cacheManager.set(
      `refresh:${refreshToken}`,
      user.id,
      this.REFRESH_TOKEN_CACHE_TTL,
    );

    // Also cache access token for validation if needed
    await this.cacheManager.set(`token:${user.id}`, accessToken, 3600000); // 1 hour

    return {
      access_token: accessToken,
      refresh_token: refreshToken,
      expires_in: 3600, // 1 hour in seconds
    };
  }

  async refreshToken(refreshToken: string) {
    // Validate refresh token exists in cache
    const userId = await this.cacheManager.get<string>(`refresh:${refreshToken}`);

    if (!userId) {
      throw new UnauthorizedException('Invalid or expired refresh token');
    }

    // Get user from database
    const user = await this.userRepository.findById(userId);
    if (!user) {
      throw new UnauthorizedException('User not found');
    }

    // Generate new tokens
    const payload = {
      username: user.username,
      sub: user.id,
      roles: user.roles,
    };

    const newAccessToken = this.jwtService.sign(payload, {
      expiresIn: this.ACCESS_TOKEN_EXPIRY,
    });

    const newRefreshToken = this.generateRefreshToken();

    // Invalidate old refresh token
    await this.cacheManager.del(`refresh:${refreshToken}`);

    // Store new refresh token
    await this.cacheManager.set(
      `refresh:${newRefreshToken}`,
      user.id,
      this.REFRESH_TOKEN_CACHE_TTL,
    );

    // Update access token cache
    await this.cacheManager.set(`token:${user.id}`, newAccessToken, 3600000);

    return {
      access_token: newAccessToken,
      refresh_token: newRefreshToken,
      expires_in: 3600,
    };
  }

  async logout(userId: string, refreshToken?: string) {
    // Invalidate access token
    await this.cacheManager.del(`token:${userId}`);

    // Invalidate refresh token if provided
    if (refreshToken) {
      await this.cacheManager.del(`refresh:${refreshToken}`);
    }
  }

  async register(registerData: {
    username: string;
    email?: string;
    password: string;
    firstName?: string;
    lastName?: string;
    phone?: string;
    identification?: string;
    country?: string;
    province?: string;
    canton?: string;
    district?: string;
    occupation?: string;
    incomeSource?: string;
    roles?: UserRole[];
  }): Promise<User> {
    // Check if username already exists
    const existingUser = await this.userRepository.findByUsername(registerData.username);
    if (existingUser) {
      throw new Error('Username already exists');
    }

    // Check if email already exists (if provided)
    if (registerData.email) {
      const existingEmail = await this.userRepository.findByEmail(registerData.email);
      if (existingEmail) {
        throw new Error('Email already exists');
      }
    }

    // Hash password
    const passwordHash = await bcrypt.hash(registerData.password, 12);

    // Create user with default role WATCHER if no roles provided
    const newUser = await this.userRepository.save({
      username: registerData.username,
      email: registerData.email,
      passwordHash,
      firstName: registerData.firstName,
      lastName: registerData.lastName,
      phone: registerData.phone,
      identification: registerData.identification,
      country: registerData.country,
      province: registerData.province,
      canton: registerData.canton,
      district: registerData.district,
      occupation: registerData.occupation,
      incomeSource: registerData.incomeSource,
      roles: registerData.roles || [UserRole.WATCHER],
      isActive: true,
      isVerified: false,
    });

    return newUser;
  }

  private generateRefreshToken(): string {
    return randomBytes(32).toString('hex');
  }

  // Helper for seeding initial admin (useful for first development run)
  async createInitialAdmin(username: string, pass: string) {
    const existing = await this.userRepository.findByUsername(username);
    if (existing) return;

    const passwordHash = await bcrypt.hash(pass, 12);
    await this.userRepository.save({
      username,
      passwordHash,
      roles: [UserRole.SUPER_USER],
    });
  }

  // Validate JWT token and return user payload
  async validateToken(token: string): Promise<{ id: string; username: string; roles: UserRole[] }> {
    try {
      const payload = this.jwtService.verify(token);
      return {
        id: payload.sub,
        username: payload.username,
        roles: payload.roles,
      };
    } catch (error) {
      throw new Error('Invalid token');
    }
  }
}
