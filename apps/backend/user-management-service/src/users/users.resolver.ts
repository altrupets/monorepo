import { Resolver, Query, Mutation, Args } from '@nestjs/graphql';
import { UseGuards, Inject } from '@nestjs/common';
import { User } from './entities/user.entity';
import { UpdateUserInput } from './dto/update-user.input';
import type { IUserRepository } from './domain/user.repository.interface';
import { IUSER_REPOSITORY } from './domain/user.repository.interface';
import { JwtAuthGuard } from '../auth/jwt-auth.guard';
import { GqlUser } from '../auth/gql-user.decorator';

@Resolver(() => User)
export class UsersResolver {
    constructor(
        @Inject(IUSER_REPOSITORY)
        private readonly userRepository: IUserRepository,
    ) { }

    @Query(() => User, { name: 'currentUser' })
    @UseGuards(JwtAuthGuard)
    async getCurrentUser(@GqlUser() user: any): Promise<User> {
        const fullUser = await this.userRepository.findById(user.userId);
        if (!fullUser) {
            throw new Error('User not found');
        }
        return fullUser;
    }

    @Mutation(() => User)
    @UseGuards(JwtAuthGuard)
    async updateUserProfile(
        @GqlUser() user: any,
        @Args('input') input: UpdateUserInput,
    ): Promise<User> {
        const existingUser = await this.userRepository.findById(user.userId);
        if (!existingUser) {
            throw new Error('User not found');
        }

        // Update fields
        Object.assign(existingUser, input);

        return this.userRepository.save(existingUser);
    }
}
