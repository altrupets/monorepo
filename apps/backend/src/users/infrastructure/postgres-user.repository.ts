import { Injectable } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { User } from '../entities/user.entity';
import { IUserRepository, PaginationOptions, PaginatedResult } from '../domain/user.repository.interface';

@Injectable()
export class PostgresUserRepository implements IUserRepository {
  constructor(
    @InjectRepository(User)
    private readonly repository: Repository<User>,
  ) {}

  async findById(id: string): Promise<User | null> {
    return this.repository.findOne({ where: { id } });
  }

  async findByUsername(username: string): Promise<User | null> {
    return this.repository.findOne({ where: { username } });
  }

  async findByEmail(email: string): Promise<User | null> {
    return this.repository.findOne({ where: { email } });
  }

  async findAll(): Promise<User[]> {
    return this.repository.find({
      order: { updatedAt: 'DESC' },
    });
  }

  async findWithPagination(options: PaginationOptions): Promise<PaginatedResult<User>> {
    const { page, limit, sortBy = 'updatedAt', order = 'DESC' } = options;
    const skip = (page - 1) * limit;

    const [items, total] = await this.repository.findAndCount({
      order: { [sortBy]: order },
      skip,
      take: limit,
    });

    const totalPages = Math.ceil(total / limit);

    return {
      items,
      total,
      page,
      limit,
      totalPages,
      hasNext: page < totalPages,
      hasPrevious: page > 1,
    };
  }

  async save(user: Partial<User>): Promise<User> {
    const newUser = this.repository.create(user);
    return this.repository.save(newUser);
  }

  async delete(id: string): Promise<void> {
    await this.repository.delete(id);
  }
}
