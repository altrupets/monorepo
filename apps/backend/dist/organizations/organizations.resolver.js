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
exports.OrganizationsResolver = void 0;
const graphql_1 = require("@nestjs/graphql");
const common_1 = require("@nestjs/common");
const organizations_service_1 = require("./organizations.service");
const organization_entity_1 = require("./entities/organization.entity");
const organization_membership_entity_1 = require("./entities/organization-membership.entity");
const register_organization_input_1 = require("./dto/register-organization.input");
const request_membership_input_1 = require("./dto/request-membership.input");
const manage_membership_input_1 = require("./dto/manage-membership.input");
const search_organizations_input_1 = require("./dto/search-organizations.input");
const jwt_auth_guard_1 = require("../auth/jwt-auth.guard");
const gql_user_decorator_1 = require("../auth/gql-user.decorator");
const user_entity_1 = require("../users/entities/user.entity");
let OrganizationsResolver = class OrganizationsResolver {
    organizationsService;
    constructor(organizationsService) {
        this.organizationsService = organizationsService;
    }
    async registerOrganization(registerOrganizationInput, user) {
        return this.organizationsService.registerOrganization(registerOrganizationInput, user.id);
    }
    async searchOrganizations(searchOrganizationsInput) {
        return this.organizationsService.searchOrganizations(searchOrganizationsInput);
    }
    async organization(id) {
        return this.organizationsService.getOrganizationById(id);
    }
    async requestMembership(requestMembershipInput, user) {
        return this.organizationsService.requestMembership(requestMembershipInput, user.id);
    }
    async approveMembership(approveMembershipInput, user) {
        return this.organizationsService.approveMembership(approveMembershipInput, user.id);
    }
    async rejectMembership(rejectMembershipInput, user) {
        return this.organizationsService.rejectMembership(rejectMembershipInput, user.id);
    }
    async assignRole(assignRoleInput, user) {
        return this.organizationsService.assignRole(assignRoleInput, user.id);
    }
    async organizationMemberships(organizationId) {
        return this.organizationsService.getOrganizationMemberships(organizationId);
    }
    async myMemberships(user) {
        return this.organizationsService.getUserMemberships(user.id);
    }
};
exports.OrganizationsResolver = OrganizationsResolver;
__decorate([
    (0, graphql_1.Mutation)(() => organization_entity_1.Organization),
    (0, common_1.UseGuards)(jwt_auth_guard_1.JwtAuthGuard),
    __param(0, (0, graphql_1.Args)('registerOrganizationInput')),
    __param(1, (0, gql_user_decorator_1.GqlUser)()),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [register_organization_input_1.RegisterOrganizationInput,
        user_entity_1.User]),
    __metadata("design:returntype", Promise)
], OrganizationsResolver.prototype, "registerOrganization", null);
__decorate([
    (0, graphql_1.Query)(() => [organization_entity_1.Organization]),
    __param(0, (0, graphql_1.Args)('searchOrganizationsInput')),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [search_organizations_input_1.SearchOrganizationsInput]),
    __metadata("design:returntype", Promise)
], OrganizationsResolver.prototype, "searchOrganizations", null);
__decorate([
    (0, graphql_1.Query)(() => organization_entity_1.Organization),
    __param(0, (0, graphql_1.Args)('id', { type: () => graphql_1.ID })),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [String]),
    __metadata("design:returntype", Promise)
], OrganizationsResolver.prototype, "organization", null);
__decorate([
    (0, graphql_1.Mutation)(() => organization_membership_entity_1.OrganizationMembership),
    (0, common_1.UseGuards)(jwt_auth_guard_1.JwtAuthGuard),
    __param(0, (0, graphql_1.Args)('requestMembershipInput')),
    __param(1, (0, gql_user_decorator_1.GqlUser)()),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [request_membership_input_1.RequestMembershipInput,
        user_entity_1.User]),
    __metadata("design:returntype", Promise)
], OrganizationsResolver.prototype, "requestMembership", null);
__decorate([
    (0, graphql_1.Mutation)(() => organization_membership_entity_1.OrganizationMembership),
    (0, common_1.UseGuards)(jwt_auth_guard_1.JwtAuthGuard),
    __param(0, (0, graphql_1.Args)('approveMembershipInput')),
    __param(1, (0, gql_user_decorator_1.GqlUser)()),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [manage_membership_input_1.ApproveMembershipInput,
        user_entity_1.User]),
    __metadata("design:returntype", Promise)
], OrganizationsResolver.prototype, "approveMembership", null);
__decorate([
    (0, graphql_1.Mutation)(() => organization_membership_entity_1.OrganizationMembership),
    (0, common_1.UseGuards)(jwt_auth_guard_1.JwtAuthGuard),
    __param(0, (0, graphql_1.Args)('rejectMembershipInput')),
    __param(1, (0, gql_user_decorator_1.GqlUser)()),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [manage_membership_input_1.RejectMembershipInput,
        user_entity_1.User]),
    __metadata("design:returntype", Promise)
], OrganizationsResolver.prototype, "rejectMembership", null);
__decorate([
    (0, graphql_1.Mutation)(() => organization_membership_entity_1.OrganizationMembership),
    (0, common_1.UseGuards)(jwt_auth_guard_1.JwtAuthGuard),
    __param(0, (0, graphql_1.Args)('assignRoleInput')),
    __param(1, (0, gql_user_decorator_1.GqlUser)()),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [manage_membership_input_1.AssignRoleInput,
        user_entity_1.User]),
    __metadata("design:returntype", Promise)
], OrganizationsResolver.prototype, "assignRole", null);
__decorate([
    (0, graphql_1.Query)(() => [organization_membership_entity_1.OrganizationMembership]),
    (0, common_1.UseGuards)(jwt_auth_guard_1.JwtAuthGuard),
    __param(0, (0, graphql_1.Args)('organizationId', { type: () => graphql_1.ID })),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [String]),
    __metadata("design:returntype", Promise)
], OrganizationsResolver.prototype, "organizationMemberships", null);
__decorate([
    (0, graphql_1.Query)(() => [organization_membership_entity_1.OrganizationMembership]),
    (0, common_1.UseGuards)(jwt_auth_guard_1.JwtAuthGuard),
    __param(0, (0, gql_user_decorator_1.GqlUser)()),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [user_entity_1.User]),
    __metadata("design:returntype", Promise)
], OrganizationsResolver.prototype, "myMemberships", null);
exports.OrganizationsResolver = OrganizationsResolver = __decorate([
    (0, graphql_1.Resolver)(() => organization_entity_1.Organization),
    __metadata("design:paramtypes", [organizations_service_1.OrganizationsService])
], OrganizationsResolver);
//# sourceMappingURL=organizations.resolver.js.map