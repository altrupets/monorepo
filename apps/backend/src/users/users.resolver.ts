import { Resolver, Query, Mutation, Args } from '@nestjs/graphql';
import { UseGuards, Inject, ForbiddenException } from '@nestjs/common';
import { User } from './entities/user.entity';
import { UpdateUserInput } from './dto/update-user.input';
import type { IUserRepository } from './domain/user.repository.interface';
import { IUSER_REPOSITORY } from './domain/user.repository.interface';
import { JwtAuthGuard } from '../auth/jwt-auth.guard';
import { GqlUser } from '../auth/gql-user.decorator';
import { Roles } from '../auth/roles/roles.decorator';
import { RolesGuard } from '../auth/roles/roles.guard';
import { USER_ADMIN_ROLES } from '../auth/roles/rbac-constants';

@Resolver(() => User)
export class UsersResolver {
    constructor(
        @Inject(IUSER_REPOSITORY)
        private readonly userRepository: IUserRepository,
    ) { }

    @Query(() => [User], { name: 'users' })
    @UseGuards(JwtAuthGuard, RolesGuard)
    @Roles(...USER_ADMIN_ROLES)
    async getUsers(): Promise<User[]> {
        const users = await this.userRepository.findAll();
        return users.map((user) => this.mapUserForResponse(user));
    }

    @Query(() => User, { name: 'user' })
    @UseGuards(JwtAuthGuard, RolesGuard)
    @Roles(...USER_ADMIN_ROLES)
    async getUser(@Args('id') id: string): Promise<User> {
        const user = await this.userRepository.findById(id);
        if (!user) {
            throw new Error('User not found');
        }
        return this.mapUserForResponse(user);
    }

    @Query(() => User, { name: 'currentUser' })
    @UseGuards(JwtAuthGuard)
    async getCurrentUser(@GqlUser() user: any): Promise<User> {
        const userId = this.getAuthenticatedUserId(user);
        const fullUser = await this.userRepository.findById(userId);
        if (!fullUser) {
            throw new Error('User not found');
        }
        return this.mapUserForResponse(fullUser);
    }

    @Mutation(() => User)
    @UseGuards(JwtAuthGuard)
    async updateUserProfile(
        @GqlUser() user: any,
        @Args('input') input: UpdateUserInput,
    ): Promise<User> {
        const userId = this.getAuthenticatedUserId(user);
        const existingUser = await this.userRepository.findById(userId);
        if (!existingUser) {
            throw new Error('User not found');
        }

        const { avatarBase64, ...profileFields } = input;
        Object.assign(existingUser, profileFields);

        if (avatarBase64 !== undefined) {
            existingUser.avatarImage = this.decodeAvatarBase64(avatarBase64);
        }

        const saved = await this.userRepository.save(existingUser);
        return this.mapUserForResponse(saved);
    }

    private getAuthenticatedUserId(user: any): string {
        const userId = user?.id ?? user?.userId;
        if (!userId) {
            throw new Error('Invalid authenticated user');
        }
        return userId;
    }

    private decodeAvatarBase64(avatarBase64: string): Buffer | null {
        const trimmed = avatarBase64.trim();
        if (trimmed.length === 0) {
            return null;
        }
        const payload = trimmed.includes(',')
            ? trimmed.split(',').pop() ?? ''
            : trimmed;

        return Buffer.from(payload, 'base64');
    }

    private mapUserForResponse(user: User): User {
        const avatarBuffer = user.avatarImage;
        user.avatarBase64 = avatarBuffer ? avatarBuffer.toString('base64') : null;
        return user;
    }
}
