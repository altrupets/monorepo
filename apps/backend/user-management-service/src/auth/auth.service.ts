import { Injectable, Inject } from '@nestjs/common';
import { UserRole } from './roles/user-role.enum';
import { JwtService } from '@nestjs/jwt';
import * as bcrypt from 'bcrypt';
import { CACHE_MANAGER } from '@nestjs/cache-manager';
import type { Cache } from 'cache-manager';
import { IUSER_REPOSITORY } from '../users/domain/user.repository.interface';
import type { IUserRepository } from '../users/domain/user.repository.interface';
import { User } from '../users/entities/user.entity';

@Injectable()
export class AuthService {
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
    const accessToken = this.jwtService.sign(payload);

    // Cache token for validation if needed (SRE best practice)
    await this.cacheManager.set(`token:${user.id}`, accessToken, 3600000); // 1 hour

    return {
      access_token: accessToken,
    };
  }

  // Helper for seeding initial admin (useful for first development run)
  async createInitialAdmin(username: string, pass: string) {
    const existing = await this.userRepository.findByUsername(username);
    if (existing) return;

    const passwordHash = await bcrypt.hash(pass, 12);
    await this.userRepository.save({
      username,
      passwordHash,
      roles: [UserRole.GOVERNMENT_ADMIN],
    });
  }
}
