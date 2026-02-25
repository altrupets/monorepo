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
Object.defineProperty(exports, "__esModule", { value: true });
exports.OrganizationMembership = exports.OrganizationRole = exports.MembershipStatus = void 0;
const typeorm_1 = require("typeorm");
const graphql_1 = require("@nestjs/graphql");
const organization_entity_1 = require("./organization.entity");
const user_entity_1 = require("../../users/entities/user.entity");
var MembershipStatus;
(function (MembershipStatus) {
    MembershipStatus["PENDING"] = "PENDING";
    MembershipStatus["APPROVED"] = "APPROVED";
    MembershipStatus["REJECTED"] = "REJECTED";
    MembershipStatus["REVOKED"] = "REVOKED";
})(MembershipStatus || (exports.MembershipStatus = MembershipStatus = {}));
var OrganizationRole;
(function (OrganizationRole) {
    OrganizationRole["LEGAL_REPRESENTATIVE"] = "LEGAL_REPRESENTATIVE";
    OrganizationRole["USER_ADMIN"] = "USER_ADMIN";
    OrganizationRole["MEMBER"] = "MEMBER";
})(OrganizationRole || (exports.OrganizationRole = OrganizationRole = {}));
let OrganizationMembership = class OrganizationMembership {
    id;
    organizationId;
    organization;
    userId;
    user;
    status;
    role;
    requestMessage;
    rejectionReason;
    approvedBy;
    approvedAt;
    createdAt;
    updatedAt;
};
exports.OrganizationMembership = OrganizationMembership;
__decorate([
    (0, graphql_1.Field)(() => graphql_1.ID),
    (0, typeorm_1.PrimaryGeneratedColumn)('uuid'),
    __metadata("design:type", String)
], OrganizationMembership.prototype, "id", void 0);
__decorate([
    (0, graphql_1.Field)(() => graphql_1.ID),
    (0, typeorm_1.Column)({ type: 'uuid' }),
    (0, typeorm_1.Index)(),
    __metadata("design:type", String)
], OrganizationMembership.prototype, "organizationId", void 0);
__decorate([
    (0, typeorm_1.ManyToOne)(() => organization_entity_1.Organization, (org) => org.memberships),
    (0, typeorm_1.JoinColumn)({ name: 'organizationId' }),
    __metadata("design:type", organization_entity_1.Organization)
], OrganizationMembership.prototype, "organization", void 0);
__decorate([
    (0, graphql_1.Field)(() => graphql_1.ID),
    (0, typeorm_1.Column)({ type: 'uuid' }),
    (0, typeorm_1.Index)(),
    __metadata("design:type", String)
], OrganizationMembership.prototype, "userId", void 0);
__decorate([
    (0, typeorm_1.ManyToOne)(() => user_entity_1.User),
    (0, typeorm_1.JoinColumn)({ name: 'userId' }),
    __metadata("design:type", user_entity_1.User)
], OrganizationMembership.prototype, "user", void 0);
__decorate([
    (0, graphql_1.Field)(() => String),
    (0, typeorm_1.Column)({
        type: 'enum',
        enum: MembershipStatus,
        default: MembershipStatus.PENDING,
    }),
    __metadata("design:type", String)
], OrganizationMembership.prototype, "status", void 0);
__decorate([
    (0, graphql_1.Field)(() => String),
    (0, typeorm_1.Column)({
        type: 'enum',
        enum: OrganizationRole,
        default: OrganizationRole.MEMBER,
    }),
    __metadata("design:type", String)
], OrganizationMembership.prototype, "role", void 0);
__decorate([
    (0, graphql_1.Field)({ nullable: true }),
    (0, typeorm_1.Column)({ type: 'text', nullable: true }),
    __metadata("design:type", String)
], OrganizationMembership.prototype, "requestMessage", void 0);
__decorate([
    (0, graphql_1.Field)({ nullable: true }),
    (0, typeorm_1.Column)({ type: 'text', nullable: true }),
    __metadata("design:type", String)
], OrganizationMembership.prototype, "rejectionReason", void 0);
__decorate([
    (0, graphql_1.Field)({ nullable: true }),
    (0, typeorm_1.Column)({ type: 'uuid', nullable: true }),
    __metadata("design:type", String)
], OrganizationMembership.prototype, "approvedBy", void 0);
__decorate([
    (0, graphql_1.Field)({ nullable: true }),
    (0, typeorm_1.Column)({ type: 'timestamp', nullable: true }),
    __metadata("design:type", Date)
], OrganizationMembership.prototype, "approvedAt", void 0);
__decorate([
    (0, graphql_1.Field)(),
    (0, typeorm_1.CreateDateColumn)(),
    __metadata("design:type", Date)
], OrganizationMembership.prototype, "createdAt", void 0);
__decorate([
    (0, graphql_1.Field)(),
    (0, typeorm_1.UpdateDateColumn)(),
    __metadata("design:type", Date)
], OrganizationMembership.prototype, "updatedAt", void 0);
exports.OrganizationMembership = OrganizationMembership = __decorate([
    (0, graphql_1.ObjectType)(),
    (0, typeorm_1.Entity)('organization_memberships'),
    (0, typeorm_1.Index)(['organizationId', 'userId'], { unique: true })
], OrganizationMembership);
//# sourceMappingURL=organization-membership.entity.js.map
