import { User } from './entities/user.entity';
import { UpdateUserInput } from './dto/update-user.input';
import type { IUserRepository } from './domain/user.repository.interface';
export declare class UsersResolver {
    private readonly userRepository;
    constructor(userRepository: IUserRepository);
    getUsers(): Promise<User[]>;
    getUser(id: string): Promise<User>;
    getCurrentUser(user: any): Promise<User>;
    updateUserProfile(user: any, input: UpdateUserInput): Promise<User>;
    private getAuthenticatedUserId;
    private decodeAvatarBase64;
    private mapUserForResponse;
}
