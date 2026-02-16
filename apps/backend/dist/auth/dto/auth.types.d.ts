import { UserRole } from '../roles/user-role.enum';
export declare class AuthPayload {
    access_token: string;
}
export declare class UserProfile {
    userId: string;
    username: string;
    roles: UserRole[];
}
