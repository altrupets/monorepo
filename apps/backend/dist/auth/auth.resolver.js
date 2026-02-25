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
exports.AuthResolver = void 0;
const graphql_1 = require("@nestjs/graphql");
const user_entity_1 = require("../users/entities/user.entity");
const common_1 = require("@nestjs/common");
const auth_service_1 = require("./auth.service");
const auth_types_1 = require("./dto/auth.types");
const login_input_1 = require("./dto/login.input");
const register_input_1 = require("./dto/register.input");
const jwt_auth_guard_1 = require("./jwt-auth.guard");
const roles_guard_1 = require("./roles/roles.guard");
const roles_decorator_1 = require("./roles/roles.decorator");
const user_role_enum_1 = require("./roles/user-role.enum");
const gql_user_decorator_1 = require("./gql-user.decorator");
let AuthResolver = class AuthResolver {
    authService;
    constructor(authService) {
        this.authService = authService;
    }
    async register(registerInput) {
        return this.authService.register(registerInput);
    }
    async login(loginInput) {
        const user = await this.authService.validateUser(loginInput.username, loginInput.password);
        if (!user) {
            throw new Error('Invalid credentials');
        }
        return this.authService.login(user);
    }
    profile(user) {
        return user;
    }
    adminOnlyData() {
        return 'This is restricted to GOVERNMENT_ADMIN only';
    }
};
exports.AuthResolver = AuthResolver;
__decorate([
    (0, graphql_1.Mutation)(() => user_entity_1.User),
    __param(0, (0, graphql_1.Args)('registerInput')),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [register_input_1.RegisterInput]),
    __metadata("design:returntype", Promise)
], AuthResolver.prototype, "register", null);
__decorate([
    (0, graphql_1.Mutation)(() => auth_types_1.AuthPayload),
    __param(0, (0, graphql_1.Args)('loginInput')),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [login_input_1.LoginInput]),
    __metadata("design:returntype", Promise)
], AuthResolver.prototype, "login", null);
__decorate([
    (0, graphql_1.Query)(() => auth_types_1.UserProfile),
    (0, common_1.UseGuards)(jwt_auth_guard_1.JwtAuthGuard),
    __param(0, (0, gql_user_decorator_1.GqlUser)()),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [user_entity_1.User]),
    __metadata("design:returntype", void 0)
], AuthResolver.prototype, "profile", null);
__decorate([
    (0, graphql_1.Query)(() => String),
    (0, common_1.UseGuards)(jwt_auth_guard_1.JwtAuthGuard, roles_guard_1.RolesGuard),
    (0, roles_decorator_1.Roles)(user_role_enum_1.UserRole.GOVERNMENT_ADMIN),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", []),
    __metadata("design:returntype", void 0)
], AuthResolver.prototype, "adminOnlyData", null);
exports.AuthResolver = AuthResolver = __decorate([
    (0, graphql_1.Resolver)(),
    __metadata("design:paramtypes", [auth_service_1.AuthService])
], AuthResolver);
//# sourceMappingURL=auth.resolver.js.map
