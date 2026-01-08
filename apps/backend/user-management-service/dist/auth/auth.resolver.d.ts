import { AuthService } from './auth.service';
import { LoginInput } from './dto/login.input';
export declare class AuthResolver {
    private authService;
    constructor(authService: AuthService);
    login(loginInput: LoginInput): Promise<{
        access_token: string;
    }>;
    profile(user: any): Promise<any>;
    adminOnlyData(): Promise<string>;
}
