import { UserRole } from '../../auth/roles/user-role.enum';
export declare class CreateUserInput {
    username: string;
    password: string;
    firstName?: string;
    lastName?: string;
    roles?: UserRole[];
    isActive?: boolean;
}
