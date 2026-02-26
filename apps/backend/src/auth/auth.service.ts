import { Injectable, Inject, UnauthorizedException, Logger } from '@nestjs/common';
import { UserRole } from './roles/user-role.enum';
import { JwtService } from '@nestjs/jwt';
import * as bcrypt from 'bcrypt';
import { createHash } from 'crypto';
import { CACHE_MANAGER } from '@nestjs/cache-manager';
import type { Cache } from 'cache-manager';
import { IUSER_REPOSITORY } from '../users/domain/user.repository.interface';
import type { IUserRepository } from '../users/domain/user.repository.interface';
import { User } from '../users/entities/user.entity';
import { randomBytes } from 'crypto';

// TODO(2FA): Add environment variable for password salt in production
// TODO(2FA): Implement TOTP or SMS-based 2FA for donations/crowdfunding
const PASSWORD_SALT = process.env.MOBILE_PASSWORD_SALT;

export enum AuthErrorType {
  USER_NOT_FOUND = 'USER_NOT_FOUND',
  INVALID_PASSWORD = 'INVALID_PASSWORD',
  ACCOUNT_LOCKED = 'ACCOUNT_LOCKED',
}

export interface ValidateUserResult {
  user?: Partial<User>;
  error?: AuthErrorType;
  errorMessage?: string;
}

@Injectable()
export class AuthService {
  private readonly logger = new Logger(AuthService.name);

  // Rate limiting: max 5 failed attempts, then lock for 15 minutes
  private readonly MAX_FAILED_ATTEMPTS = 5;
  private readonly LOCK_DURATION_MS = 15 * 60 * 1000; // 15 minutes
  private readonly failedAttempts = new Map<string, { count: number; lockedUntil?: number }>();

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
  ): Promise<Partial<User>> {
    this.logger.debug(`[validateUser] ============================================================`);
    this.logger.debug(`[validateUser] LOGIN VALIDATION - Username: ${username}`);
    this.logger.debug(`[validateUser] ============================================================`);

    // Check if account is locked
    const attempts = this.failedAttempts.get(username);
    const now = Date.now();

    if (attempts?.lockedUntil && now < attempts.lockedUntil) {
      const remainingMinutes = Math.ceil((attempts.lockedUntil - now) / 60000);
      this.logger.warn(`[validateUser] Cuenta bloqueada para ${username}. Intentos: ${attempts.count}. Bloqueado por ${remainingMinutes} minutos más.`);
      throw new Error(`ACCOUNT_LOCKED: Tu cuenta está temporalmente bloqueada. Intenta de nuevo en ${remainingMinutes} minutos.`);
    }

    this.logger.debug(`[validateUser] Buscando usuario en base de datos: ${username}`);
    const user = await this.userRepository.findByUsername(username);

    if (!user) {
      this.logger.warn(`[validateUser] Usuario NO encontrado en BD: ${username}`);
      // Registrar intento fallido
      this.recordFailedAttempt(username);
      throw new Error('USER_NOT_FOUND: El usuario no existe o fue eliminado de nuestra base de datos.');
    }

    this.logger.debug(`[validateUser] Usuario encontrado en BD: ${user.username}, ID: ${user.id}`);
    this.logger.debug(`[validateUser] ------------------------------------------------------------`);

    // Compare double hash: SHA256(SHA256(password) + PASSWORD_SALT + username)
    // Mobile sends: SHA256(SHA256(password) + PASSWORD_SALT + username)
    if (!PASSWORD_SALT) {
      this.logger.error('[validateUser] PASSWORD_SALT no esta configurado en el environment');
      throw new Error('Error de configuracion del servidor');
    }

    // First hash: SHA256(password)
    const firstHash = createHash('sha256').update(pass).digest('hex');
    // Second hash: SHA256(firstHash + PASSWORD_SALT + username)
    const combined = firstHash + PASSWORD_SALT + username.toLowerCase();
    const inputHash = createHash('sha256').update(combined).digest('hex');

    this.logger.debug(`[validateUser] PASSWORD_SALT (first 16 chars): ${PASSWORD_SALT.substring(0, 16)}...`);
    this.logger.debug(`[validateUser] Password: ${pass}`);
    this.logger.debug(`[validateUser] Username: ${username.toLowerCase()}`);
    this.logger.debug(`[validateUser] First hash (SHA256 of password): ${firstHash}`);
    this.logger.debug(`[validateUser] Combined string (first 50 chars): ${combined.substring(0, 50)}...`);
    this.logger.debug(`[validateUser] Input hash (first 16 chars): ${inputHash.substring(0, 16)}...`);
    this.logger.debug(`[validateUser] Stored hash (first 16 chars): ${user.passwordHash?.substring(0, 16) || 'NULL'}...`);
    this.logger.debug(`[validateUser] ------------------------------------------------------------`);

    const isPasswordValid = inputHash === user.passwordHash;

    if (isPasswordValid) {
      this.logger.debug('[validateUser] ============================================================');
      this.logger.debug('[validateUser] PASSWORD MATCH - Login successful!');
      this.logger.debug('[validateUser] ============================================================');
    }

    if (!isPasswordValid) {
      this.logger.warn(`[validateUser] Contraseña incorrecta para usuario: ${username}`);
      // Registrar intento fallido
      this.recordFailedAttempt(username);
      throw new Error('INVALID_PASSWORD: La contraseña es incorrecta. Por favor intenta de nuevo.');
    }

    // Login exitoso - limpiar intentos fallidos
    this.failedAttempts.delete(username);
    this.logger.log('============================================================');
    this.logger.log(`[validateUser] LOGIN SUCCESS - Username: ${username}`);
    this.logger.log('============================================================');

    const result: Record<string, unknown> = { ...user };
    delete result.passwordHash;
    return result as Partial<User>;
  }

  private recordFailedAttempt(username: string): void {
    const attempts = this.failedAttempts.get(username) || { count: 0 };
    attempts.count++;

    if (attempts.count >= this.MAX_FAILED_ATTEMPTS) {
      attempts.lockedUntil = Date.now() + this.LOCK_DURATION_MS;
      this.logger.warn(`[validateUser] Cuenta bloqueada por intentos fallidos: ${username}. Intentos: ${attempts.count}`);
    }

    this.failedAttempts.set(username, attempts);
    this.logger.debug(`[validateUser] Intentos fallidos registrados para ${username}: ${attempts.count}`);
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

    // Hash password with salt using double SHA-256
    // Hash = SHA256(SHA256(password) + PASSWORD_SALT + username)
    if (!PASSWORD_SALT) {
      this.logger.error('[register] PASSWORD_SALT no esta configurado en el environment');
      throw new Error('Error de configuracion del servidor');
    }

    const firstHash = createHash('sha256').update(registerData.password).digest('hex');
    const combined = firstHash + PASSWORD_SALT + registerData.username.toLowerCase();
    const passwordHash = createHash('sha256').update(combined).digest('hex');

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
