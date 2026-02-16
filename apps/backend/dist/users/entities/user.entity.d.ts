import { UserRole } from '../../auth/roles/user-role.enum';
export declare class User {
    id: string;
    username: string;
    passwordHash: string;
    roles: UserRole[];
    firstName?: string;
    lastName?: string;
    phone?: string;
    identification?: string;
    country?: string;
    province?: string;
    canton?: string;
    district?: string;
    avatarImage?: Buffer | null;
    avatarBase64?: string | null;
    createdAt: Date;
    updatedAt: Date;
}
