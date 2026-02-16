import { Repository } from 'typeorm';
import { User } from '../entities/user.entity';
import { IUserRepository } from '../domain/user.repository.interface';
export declare class PostgresUserRepository implements IUserRepository {
    private readonly repository;
    constructor(repository: Repository<User>);
    findById(id: string): Promise<User | null>;
    findByUsername(username: string): Promise<User | null>;
    findAll(): Promise<User[]>;
    save(user: Partial<User>): Promise<User>;
}
