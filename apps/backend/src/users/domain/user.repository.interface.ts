import { User } from '../entities/user.entity';

export const IUSER_REPOSITORY = 'IUserRepository';

export interface PaginationOptions {
  page: number;
  limit: number;
  sortBy?: string;
  order?: 'ASC' | 'DESC';
}

export interface PaginatedResult<T> {
  items: T[];
  total: number;
  page: number;
  limit: number;
  totalPages: number;
  hasNext: boolean;
  hasPrevious: boolean;
}

export interface IUserRepository {
  findById(id: string): Promise<User | null>;
  findByUsername(username: string): Promise<User | null>;
  findByEmail(email: string): Promise<User | null>;
  findAll(): Promise<User[]>;
  findWithPagination(options: PaginationOptions): Promise<PaginatedResult<User>>;
  save(user: Partial<User>): Promise<User>;
  delete(id: string): Promise<void>;
}
