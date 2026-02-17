import { User } from '../entities/user.entity';

export const IUSER_REPOSITORY = 'IUserRepository';

export interface IUserRepository {
  findById(id: string): Promise<User | null>;
  findByUsername(username: string): Promise<User | null>;
  findByEmail(email: string): Promise<User | null>;
  findAll(): Promise<User[]>;
  save(user: Partial<User>): Promise<User>;
}
