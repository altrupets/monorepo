import { Resolver, Query, Mutation, Args } from '@nestjs/graphql';
import { UseGuards, Inject, ForbiddenException, NotFoundException } from '@nestjs/common';
import { User } from './entities/user.entity';
import { CreateUserInput } from './dto/create-user.input';
import { UpdateUserInput } from './dto/update-user.input';
import type { IUserRepository } from './domain/user.repository.interface';
import { IUSER_REPOSITORY } from './domain/user.repository.interface';
import { JwtAuthGuard } from '../auth/jwt-auth.guard';
import { GqlUser } from '../auth/gql-user.decorator';
import { Roles } from '../auth/roles/roles.decorator';
import { RolesGuard } from '../auth/roles/roles.guard';
import { USER_ADMIN_ROLES } from '../auth/roles/rbac-constants';
import { UserRole } from '../auth/roles/user-role.enum';
import { AvatarStorageService } from './services/avatar-storage.service';
import * as bcrypt from 'bcrypt';

@Resolver(() => User)
export class UsersResolver {
    constructor(
        @Inject(IUSER_REPOSITORY)
        private readonly userRepository: IUserRepository,
        private readonly avatarStorageService: AvatarStorageService,
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
            throw new NotFoundException('User not found');
        }
        return this.mapUserForResponse(user);
    }

    @Query(() => User, { name: 'currentUser' })
    @UseGuards(JwtAuthGuard)
    async getCurrentUser(@GqlUser() user: any): Promise<User> {
        const userId = this.getAuthenticatedUserId(user);
        const fullUser = await this.userRepository.findById(userId);
        if (!fullUser) {
            throw new NotFoundException('User not found');
        }
        return this.mapUserForResponse(fullUser);
    }

    @Mutation(() => User)
    @UseGuards(JwtAuthGuard, RolesGuard)
    @Roles(...USER_ADMIN_ROLES)
    async createUser(
        @Args('input') input: CreateUserInput,
        @GqlUser() adminUser: any,
    ): Promise<User> {
        const existing = await this.userRepository.findByUsername(input.username);
        if (existing) {
            throw new ForbiddenException('Username already exists');
        }

        const adminRoles = adminUser.roles as UserRole[];
        const canCreateSuperUser = adminRoles.includes(UserRole.SUPER_USER);
        
        if (input.roles?.includes(UserRole.SUPER_USER) && !canCreateSuperUser) {
            throw new ForbiddenException('Only SUPER_USER can create other SUPER_USER accounts');
        }

        const passwordHash = await bcrypt.hash(input.password, 12);
        
        const user = await this.userRepository.save({
            username: input.username,
            passwordHash,
            firstName: input.firstName,
            lastName: input.lastName,
            roles: input.roles || [UserRole.WATCHER],
            isActive: input.isActive ?? true,
        });

        return this.mapUserForResponse(user);
    }

    @Mutation(() => User)
    @UseGuards(JwtAuthGuard, RolesGuard)
    @Roles(...USER_ADMIN_ROLES)
    async updateUser(
        @Args('id') id: string,
        @Args('input') input: UpdateUserInput,
        @GqlUser() adminUser: any,
    ): Promise<User> {
        const user = await this.userRepository.findById(id);
        if (!user) {
            throw new NotFoundException('User not found');
        }

        const adminRoles = adminUser.roles as UserRole[];
        const canModifySuperUser = adminRoles.includes(UserRole.SUPER_USER);

        if (user.roles.includes(UserRole.SUPER_USER) && !canModifySuperUser) {
            throw new ForbiddenException('Only SUPER_USER can modify other SUPER_USER accounts');
        }

        if (input.roles?.includes(UserRole.SUPER_USER) && !canModifySuperUser) {
            throw new ForbiddenException('Only SUPER_USER can assign SUPER_USER role');
        }

        if (input.roles) {
            user.roles = input.roles;
        }
        if (input.isActive !== undefined) {
            user.isActive = input.isActive;
        }
        if (input.firstName !== undefined) {
            user.firstName = input.firstName;
        }
        if (input.lastName !== undefined) {
            user.lastName = input.lastName;
        }

        const saved = await this.userRepository.save(user);
        return this.mapUserForResponse(saved);
    }

    @Mutation(() => Boolean)
    @UseGuards(JwtAuthGuard, RolesGuard)
    @Roles(...USER_ADMIN_ROLES)
    async deleteUser(
        @Args('id') id: string,
        @GqlUser() adminUser: any,
    ): Promise<boolean> {
        const user = await this.userRepository.findById(id);
        if (!user) {
            throw new NotFoundException('User not found');
        }

        const adminRoles = adminUser.roles as UserRole[];
        const canDeleteSuperUser = adminRoles.includes(UserRole.SUPER_USER);

        if (user.roles.includes(UserRole.SUPER_USER) && !canDeleteSuperUser) {
            throw new ForbiddenException('Only SUPER_USER can delete other SUPER_USER accounts');
        }

        if (user.id === adminUser.id || user.id === adminUser.userId) {
            throw new ForbiddenException('Cannot delete your own account');
        }

        await this.userRepository.delete(id);
        return true;
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
            throw new NotFoundException('User not found');
        }

        const { avatarBase64, roles, isActive, ...profileFields } = input;
        Object.assign(existingUser, profileFields);

        if (avatarBase64 !== undefined) {
            // Support both legacy BLOB and new URL-based storage
            const imageBuffer = this.decodeAvatarBase64(avatarBase64);
            
            if (imageBuffer) {
                // Upload to storage service (S3/MinIO or local)
                const uploadResult = await this.avatarStorageService.uploadAvatar(userId, imageBuffer);
                existingUser.avatarUrl = uploadResult.url;
                existingUser.avatarStorageProvider = uploadResult.storageProvider;
                
                // Keep BLOB for backward compatibility during migration
                existingUser.avatarImage = imageBuffer;
            } else {
                // Clear avatar if empty
                existingUser.avatarUrl = null;
                existingUser.avatarStorageProvider = null;
                existingUser.avatarImage = null;
            }
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
