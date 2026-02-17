"use strict";
var __decorate = (this && this.__decorate) || function (decorators, target, key, desc) {
    var c = arguments.length, r = c < 3 ? target : desc === null ? desc = Object.getOwnPropertyDescriptor(target, key) : desc, d;
    if (typeof Reflect === "object" && typeof Reflect.decorate === "function") r = Reflect.decorate(decorators, target, key, desc);
    else for (var i = decorators.length - 1; i >= 0; i--) if (d = decorators[i]) r = (c < 3 ? d(r) : c > 3 ? d(target, key, r) : d(target, key)) || r;
    return c > 3 && r && Object.defineProperty(target, key, r), r;
};
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
const update_user_input_1 = require("./dto/update-user.input");
const user_repository_interface_1 = require("./domain/user.repository.interface");
const jwt_auth_guard_1 = require("../auth/jwt-auth.guard");
const gql_user_decorator_1 = require("../auth/gql-user.decorator");
const roles_decorator_1 = require("../auth/roles/roles.decorator");
const roles_guard_1 = require("../auth/roles/roles.guard");
const rbac_constants_1 = require("../auth/roles/rbac-constants");
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
            throw new Error('User not found');
        }
        return this.mapUserForResponse(user);
    }
    async getCurrentUser(user) {
        const userId = this.getAuthenticatedUserId(user);
        const fullUser = await this.userRepository.findById(userId);
        if (!fullUser) {
            throw new Error('User not found');
        }
        return this.mapUserForResponse(fullUser);
    }
    async updateUserProfile(user, input) {
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