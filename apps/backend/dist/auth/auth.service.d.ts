import { UserRole } from './roles/user-role.enum';
import { JwtService } from '@nestjs/jwt';
import type { Cache } from 'cache-manager';
import type { IUserRepository } from '../users/domain/user.repository.interface';
import { User } from '../users/entities/user.entity';
export declare class AuthService {
    private readonly userRepository;
    private readonly jwtService;
    private readonly cacheManager;
    private readonly ACCESS_TOKEN_EXPIRY;
    private readonly REFRESH_TOKEN_EXPIRY;
    private readonly REFRESH_TOKEN_CACHE_TTL;
    constructor(userRepository: IUserRepository, jwtService: JwtService, cacheManager: Cache);
    validateUser(username: string, pass: string): Promise<Partial<User> | null>;
    login(user: Partial<User>): Promise<{
        access_token: string;
        refresh_token: string;
        expires_in: number;
    }>;
    refreshToken(refreshToken: string): Promise<{
        access_token: string;
        refresh_token: string;
        expires_in: number;
    }>;
    logout(userId: string, refreshToken?: string): Promise<void>;
    register(registerData: {
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
    }): Promise<User>;
    private generateRefreshToken;
    createInitialAdmin(username: string, pass: string): Promise<void>;
    validateToken(token: string): Promise<{
        id: string;
        username: string;
        roles: UserRole[];
    }>;
}
