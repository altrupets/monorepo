import { UserRole } from '../roles/user-role.enum';
export declare class AuthPayload {
    access_token: string;
    refresh_token: string;
    expires_in: number;
}
export declare class UserProfile {
    userId: string;
    username: string;
    roles: UserRole[];
}
export declare class RefreshTokenInput {
    refresh_token: string;
}
