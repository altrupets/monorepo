import { UserRole } from '../../auth/roles/user-role.enum';
export declare class User {
    id: string;
    username: string;
    passwordHash: string;
    roles: UserRole[];
    createdAt: Date;
    updatedAt: Date;
}
