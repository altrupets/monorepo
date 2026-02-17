import { UserRole } from '../roles/user-role.enum';
export declare class RegisterInput {
    username: string;
    email?: string;
    password: string;
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
    roles?: UserRole[];
}
