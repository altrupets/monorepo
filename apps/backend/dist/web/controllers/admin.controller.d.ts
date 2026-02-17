import type { Response } from 'express';
export declare class AdminController {
    index(res: Response): Promise<any>;
    users(res: Response): Promise<any>;
    userDetail(res: Response): Promise<any>;
}
