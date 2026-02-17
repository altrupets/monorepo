import { User } from './entities/user.entity';
import { CreateUserInput } from './dto/create-user.input';
import { UpdateUserInput } from './dto/update-user.input';
import type { IUserRepository } from './domain/user.repository.interface';
export declare class UsersResolver {
    private readonly userRepository;
    constructor(userRepository: IUserRepository);
    getUsers(): Promise<User[]>;
    getUser(id: string): Promise<User>;
    getCurrentUser(user: any): Promise<User>;
    createUser(input: CreateUserInput, adminUser: any): Promise<User>;
    updateUser(id: string, input: UpdateUserInput, adminUser: any): Promise<User>;
    deleteUser(id: string, adminUser: any): Promise<boolean>;
    updateUserProfile(user: any, input: UpdateUserInput): Promise<User>;
    private getAuthenticatedUserId;
    private decodeAvatarBase64;
    private mapUserForResponse;
}
