"use strict";
var __createBinding = (this && this.__createBinding) || (Object.create ? (function(o, m, k, k2) {
    if (k2 === undefined) k2 = k;
    var desc = Object.getOwnPropertyDescriptor(m, k);
    if (!desc || ("get" in desc ? !m.__esModule : desc.writable || desc.configurable)) {
      desc = { enumerable: true, get: function() { return m[k]; } };
    }
    Object.defineProperty(o, k2, desc);
}) : (function(o, m, k, k2) {
    if (k2 === undefined) k2 = k;
    o[k2] = m[k];
}));
var __setModuleDefault = (this && this.__setModuleDefault) || (Object.create ? (function(o, v) {
    Object.defineProperty(o, "default", { enumerable: true, value: v });
}) : function(o, v) {
    o["default"] = v;
});
var __decorate = (this && this.__decorate) || function (decorators, target, key, desc) {
    var c = arguments.length, r = c < 3 ? target : desc === null ? desc = Object.getOwnPropertyDescriptor(target, key) : desc, d;
    if (typeof Reflect === "object" && typeof Reflect.decorate === "function") r = Reflect.decorate(decorators, target, key, desc);
    else for (var i = decorators.length - 1; i >= 0; i--) if (d = decorators[i]) r = (c < 3 ? d(r) : c > 3 ? d(target, key, r) : d(target, key)) || r;
    return c > 3 && r && Object.defineProperty(target, key, r), r;
};
var __importStar = (this && this.__importStar) || (function () {
    var ownKeys = function(o) {
        ownKeys = Object.getOwnPropertyNames || function (o) {
            var ar = [];
            for (var k in o) if (Object.prototype.hasOwnProperty.call(o, k)) ar[ar.length] = k;
            return ar;
        };
        return ownKeys(o);
    };
    return function (mod) {
        if (mod && mod.__esModule) return mod;
        var result = {};
        if (mod != null) for (var k = ownKeys(mod), i = 0; i < k.length; i++) if (k[i] !== "default") __createBinding(result, mod, k[i]);
        __setModuleDefault(result, mod);
        return result;
    };
})();
var __metadata = (this && this.__metadata) || function (k, v) {
    if (typeof Reflect === "object" && typeof Reflect.metadata === "function") return Reflect.metadata(k, v);
};
var __param = (this && this.__param) || function (paramIndex, decorator) {
    return function (target, key) { decorator(target, key, paramIndex); }
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.UsersResolver = void 0;
const graphql_1 = require("@nestjs/graphql");
const common_1 = require("@nestjs/common");
const user_entity_1 = require("./entities/user.entity");
const create_user_input_1 = require("./dto/create-user.input");
const update_user_input_1 = require("./dto/update-user.input");
const user_repository_interface_1 = require("./domain/user.repository.interface");
const jwt_auth_guard_1 = require("../auth/jwt-auth.guard");
const gql_user_decorator_1 = require("../auth/gql-user.decorator");
const roles_decorator_1 = require("../auth/roles/roles.decorator");
const roles_guard_1 = require("../auth/roles/roles.guard");
const rbac_constants_1 = require("../auth/roles/rbac-constants");
const user_role_enum_1 = require("../auth/roles/user-role.enum");
const bcrypt = __importStar(require("bcrypt"));
let UsersResolver = class UsersResolver {
    userRepository;
    constructor(userRepository) {
        this.userRepository = userRepository;
    }
    async getUsers() {
        const users = await this.userRepository.findAll();
        return users.map((user) => this.mapUserForResponse(user));
    }
    async getUser(id) {
        const user = await this.userRepository.findById(id);
        if (!user) {
            throw new common_1.NotFoundException('User not found');
        }
        return this.mapUserForResponse(user);
    }
    async getCurrentUser(user) {
        const userId = this.getAuthenticatedUserId(user);
        const fullUser = await this.userRepository.findById(userId);
        if (!fullUser) {
            throw new common_1.NotFoundException('User not found');
        }
        return this.mapUserForResponse(fullUser);
    }
    async createUser(input, adminUser) {
        const existing = await this.userRepository.findByUsername(input.username);
        if (existing) {
            throw new common_1.ForbiddenException('Username already exists');
        }
        const adminRoles = adminUser.roles;
        const canCreateSuperUser = adminRoles.includes(user_role_enum_1.UserRole.SUPER_USER);
        if (input.roles?.includes(user_role_enum_1.UserRole.SUPER_USER) && !canCreateSuperUser) {
            throw new common_1.ForbiddenException('Only SUPER_USER can create other SUPER_USER accounts');
        }
        const passwordHash = await bcrypt.hash(input.password, 12);
        const user = await this.userRepository.save({
            username: input.username,
            passwordHash,
            firstName: input.firstName,
            lastName: input.lastName,
            roles: input.roles || [user_role_enum_1.UserRole.WATCHER],
            isActive: input.isActive ?? true,
        });
        return this.mapUserForResponse(user);
    }
    async updateUser(id, input, adminUser) {
        const user = await this.userRepository.findById(id);
        if (!user) {
            throw new common_1.NotFoundException('User not found');
        }
        const adminRoles = adminUser.roles;
        const canModifySuperUser = adminRoles.includes(user_role_enum_1.UserRole.SUPER_USER);
        if (user.roles.includes(user_role_enum_1.UserRole.SUPER_USER) && !canModifySuperUser) {
            throw new common_1.ForbiddenException('Only SUPER_USER can modify other SUPER_USER accounts');
        }
        if (input.roles?.includes(user_role_enum_1.UserRole.SUPER_USER) && !canModifySuperUser) {
            throw new common_1.ForbiddenException('Only SUPER_USER can assign SUPER_USER role');
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
    async deleteUser(id, adminUser) {
        const user = await this.userRepository.findById(id);
        if (!user) {
            throw new common_1.NotFoundException('User not found');
        }
        const adminRoles = adminUser.roles;
        const canDeleteSuperUser = adminRoles.includes(user_role_enum_1.UserRole.SUPER_USER);
        if (user.roles.includes(user_role_enum_1.UserRole.SUPER_USER) && !canDeleteSuperUser) {
            throw new common_1.ForbiddenException('Only SUPER_USER can delete other SUPER_USER accounts');
        }
        if (user.id === adminUser.id || user.id === adminUser.userId) {
            throw new common_1.ForbiddenException('Cannot delete your own account');
        }
        await this.userRepository.delete(id);
        return true;
    }
    async updateUserProfile(user, input) {
        const userId = this.getAuthenticatedUserId(user);
        const existingUser = await this.userRepository.findById(userId);
        if (!existingUser) {
            throw new common_1.NotFoundException('User not found');
        }
        const { avatarBase64, roles, isActive, ...profileFields } = input;
        Object.assign(existingUser, profileFields);
        if (avatarBase64 !== undefined) {
            existingUser.avatarImage = this.decodeAvatarBase64(avatarBase64);
        }
        const saved = await this.userRepository.save(existingUser);
        return this.mapUserForResponse(saved);
    }
    getAuthenticatedUserId(user) {
        const userId = user?.id ?? user?.userId;
        if (!userId) {
            throw new Error('Invalid authenticated user');
        }
        return userId;
    }
    decodeAvatarBase64(avatarBase64) {
        const trimmed = avatarBase64.trim();
        if (trimmed.length === 0) {
            return null;
        }
        const payload = trimmed.includes(',')
            ? trimmed.split(',').pop() ?? ''
            : trimmed;
        return Buffer.from(payload, 'base64');
    }
    mapUserForResponse(user) {
        const avatarBuffer = user.avatarImage;
        user.avatarBase64 = avatarBuffer ? avatarBuffer.toString('base64') : null;
        return user;
    }
};
exports.UsersResolver = UsersResolver;
__decorate([
    (0, graphql_1.Query)(() => [user_entity_1.User], { name: 'users' }),
    (0, common_1.UseGuards)(jwt_auth_guard_1.JwtAuthGuard, roles_guard_1.RolesGuard),
    (0, roles_decorator_1.Roles)(...rbac_constants_1.USER_ADMIN_ROLES),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", []),
    __metadata("design:returntype", Promise)
], UsersResolver.prototype, "getUsers", null);
__decorate([
    (0, graphql_1.Query)(() => user_entity_1.User, { name: 'user' }),
    (0, common_1.UseGuards)(jwt_auth_guard_1.JwtAuthGuard, roles_guard_1.RolesGuard),
    (0, roles_decorator_1.Roles)(...rbac_constants_1.USER_ADMIN_ROLES),
    __param(0, (0, graphql_1.Args)('id')),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [String]),
    __metadata("design:returntype", Promise)
], UsersResolver.prototype, "getUser", null);
__decorate([
    (0, graphql_1.Query)(() => user_entity_1.User, { name: 'currentUser' }),
    (0, common_1.UseGuards)(jwt_auth_guard_1.JwtAuthGuard),
    __param(0, (0, gql_user_decorator_1.GqlUser)()),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [Object]),
    __metadata("design:returntype", Promise)
], UsersResolver.prototype, "getCurrentUser", null);
__decorate([
    (0, graphql_1.Mutation)(() => user_entity_1.User),
    (0, common_1.UseGuards)(jwt_auth_guard_1.JwtAuthGuard, roles_guard_1.RolesGuard),
    (0, roles_decorator_1.Roles)(...rbac_constants_1.USER_ADMIN_ROLES),
    __param(0, (0, graphql_1.Args)('input')),
    __param(1, (0, gql_user_decorator_1.GqlUser)()),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [create_user_input_1.CreateUserInput, Object]),
    __metadata("design:returntype", Promise)
], UsersResolver.prototype, "createUser", null);
__decorate([
    (0, graphql_1.Mutation)(() => user_entity_1.User),
    (0, common_1.UseGuards)(jwt_auth_guard_1.JwtAuthGuard, roles_guard_1.RolesGuard),
    (0, roles_decorator_1.Roles)(...rbac_constants_1.USER_ADMIN_ROLES),
    __param(0, (0, graphql_1.Args)('id')),
    __param(1, (0, graphql_1.Args)('input')),
    __param(2, (0, gql_user_decorator_1.GqlUser)()),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [String, update_user_input_1.UpdateUserInput, Object]),
    __metadata("design:returntype", Promise)
], UsersResolver.prototype, "updateUser", null);
__decorate([
    (0, graphql_1.Mutation)(() => Boolean),
    (0, common_1.UseGuards)(jwt_auth_guard_1.JwtAuthGuard, roles_guard_1.RolesGuard),
    (0, roles_decorator_1.Roles)(...rbac_constants_1.USER_ADMIN_ROLES),
    __param(0, (0, graphql_1.Args)('id')),
    __param(1, (0, gql_user_decorator_1.GqlUser)()),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [String, Object]),
    __metadata("design:returntype", Promise)
], UsersResolver.prototype, "deleteUser", null);
__decorate([
    (0, graphql_1.Mutation)(() => user_entity_1.User),
    (0, common_1.UseGuards)(jwt_auth_guard_1.JwtAuthGuard),
    __param(0, (0, gql_user_decorator_1.GqlUser)()),
    __param(1, (0, graphql_1.Args)('input')),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [Object, update_user_input_1.UpdateUserInput]),
    __metadata("design:returntype", Promise)
], UsersResolver.prototype, "updateUserProfile", null);
exports.UsersResolver = UsersResolver = __decorate([
    (0, graphql_1.Resolver)(() => user_entity_1.User),
    __param(0, (0, common_1.Inject)(user_repository_interface_1.IUSER_REPOSITORY)),
    __metadata("design:paramtypes", [Object])
], UsersResolver);
//# sourceMappingURL=users.resolver.js.map