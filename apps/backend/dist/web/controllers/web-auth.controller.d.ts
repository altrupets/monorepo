import type { Response } from 'express';
import { AuthService } from '../../auth/auth.service';
export declare class WebAuthController {
    private readonly authService;
    constructor(authService: AuthService);
    loginPage(res: Response): Promise<any>;
    login(loginInput: {
        username: string;
        password: string;
    }, res: Response): Promise<any>;
    logout(res: Response): Promise<void>;
}
