import { UserRole } from '../../auth/roles/user-role.enum';
export declare class User {
    id: string;
    username: string;
    email?: string;
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
    bio?: string;
    occupation?: string;
    incomeSource?: string;
    organizationId?: string;
    latitude?: number;
    longitude?: number;
    isActive: boolean;
    isVerified: boolean;
    avatarImage?: Buffer | null;
    avatarBase64?: string | null;
    createdAt: Date;
    updatedAt: Date;
}
