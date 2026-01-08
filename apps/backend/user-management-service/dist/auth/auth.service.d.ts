import { JwtService } from '@nestjs/jwt';
import type { Cache } from 'cache-manager';
import type { IUserRepository } from '../users/domain/user.repository.interface';
export declare class AuthService {
    private readonly userRepository;
    private readonly jwtService;
    private readonly cacheManager;
    constructor(userRepository: IUserRepository, jwtService: JwtService, cacheManager: Cache);
    validateUser(username: string, pass: string): Promise<any>;
    login(user: any): Promise<{
        access_token: string;
    }>;
    createInitialAdmin(username: string, pass: string): Promise<void>;
}
