import { User } from '../entities/user.entity';
export declare const IUSER_REPOSITORY = "IUserRepository";
export interface IUserRepository {
    findById(id: string): Promise<User | null>;
    findByUsername(username: string): Promise<User | null>;
    save(user: Partial<User>): Promise<User>;
}
