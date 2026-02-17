import { UserRole } from '../../auth/roles/user-role.enum';
export declare class UpdateUserInput {
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
    latitude?: number;
    longitude?: number;
    avatarBase64?: string;
    roles?: UserRole[];
    isActive?: boolean;
}
