import { User } from '../users/entities/user.entity';
import { AuthService } from './auth.service';
import { LoginInput } from './dto/login.input';
import { RegisterInput } from './dto/register.input';
export declare class AuthResolver {
    private authService;
    constructor(authService: AuthService);
    register(registerInput: RegisterInput): Promise<User>;
    login(loginInput: LoginInput): Promise<{
        access_token: string;
        refresh_token: string;
        expires_in: number;
    }>;
    profile(user: User): User;
    adminOnlyData(): string;
}
