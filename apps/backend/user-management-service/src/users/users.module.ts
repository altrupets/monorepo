import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { User } from './entities/user.entity';
import { IUSER_REPOSITORY } from './domain/user.repository.interface';
import { PostgresUserRepository } from './infrastructure/postgres-user.repository';

@Module({
  imports: [TypeOrmModule.forFeature([User])],
  providers: [
    {
      provide: IUSER_REPOSITORY,
      useClass: PostgresUserRepository,
    },
  ],
  exports: [IUSER_REPOSITORY],
})
export class UsersModule {}
