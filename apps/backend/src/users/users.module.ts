import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { User } from './entities/user.entity';
import { IUSER_REPOSITORY } from './domain/user.repository.interface';
import { PostgresUserRepository } from './infrastructure/postgres-user.repository';
import { UsersResolver } from './users.resolver';
import { AvatarStorageService } from './services/avatar-storage.service';

@Module({
  imports: [TypeOrmModule.forFeature([User])],
  providers: [
    UsersResolver,
    AvatarStorageService,
    {
      provide: IUSER_REPOSITORY,
      useClass: PostgresUserRepository,
    },
  ],
  exports: [IUSER_REPOSITORY, AvatarStorageService],
})
export class UsersModule { }
