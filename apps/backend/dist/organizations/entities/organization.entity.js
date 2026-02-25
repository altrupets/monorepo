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
exports.Organization = exports.OrganizationStatus = exports.OrganizationType = void 0;
const typeorm_1 = require("typeorm");
const graphql_1 = require("@nestjs/graphql");
const organization_membership_entity_1 = require("./organization-membership.entity");
var OrganizationType;
(function (OrganizationType) {
    OrganizationType["FOUNDATION"] = "FOUNDATION";
    OrganizationType["ASSOCIATION"] = "ASSOCIATION";
    OrganizationType["NGO"] = "NGO";
    OrganizationType["COOPERATIVE"] = "COOPERATIVE";
    OrganizationType["GOVERNMENT"] = "GOVERNMENT";
    OrganizationType["OTHER"] = "OTHER";
})(OrganizationType || (exports.OrganizationType = OrganizationType = {}));
var OrganizationStatus;
(function (OrganizationStatus) {
    OrganizationStatus["PENDING_VERIFICATION"] = "PENDING_VERIFICATION";
    OrganizationStatus["ACTIVE"] = "ACTIVE";
    OrganizationStatus["SUSPENDED"] = "SUSPENDED";
    OrganizationStatus["INACTIVE"] = "INACTIVE";
})(OrganizationStatus || (exports.OrganizationStatus = OrganizationStatus = {}));
let Organization = class Organization {
    id;
    name;
    type;
    legalId;
    description;
    email;
    phone;
    website;
    address;
    country;
    province;
    canton;
    district;
    status;
    legalDocumentation;
    legalDocumentationBase64;
    financialStatements;
    financialStatementsBase64;
    legalRepresentativeId;
    memberCount;
    maxCapacity;
    isActive;
    isVerified;
    memberships;
    createdAt;
    updatedAt;
};
exports.Organization = Organization;
__decorate([
    (0, graphql_1.Field)(() => graphql_1.ID),
    (0, typeorm_1.PrimaryGeneratedColumn)('uuid'),
    __metadata("design:type", String)
], Organization.prototype, "id", void 0);
__decorate([
    (0, graphql_1.Field)(),
    (0, typeorm_1.Column)({ unique: true }),
    (0, typeorm_1.Index)(),
    __metadata("design:type", String)
], Organization.prototype, "name", void 0);
__decorate([
    (0, graphql_1.Field)(() => String),
    (0, typeorm_1.Column)({
        type: 'enum',
        enum: OrganizationType,
        default: OrganizationType.ASSOCIATION,
    }),
    __metadata("design:type", String)
], Organization.prototype, "type", void 0);
__decorate([
    (0, graphql_1.Field)({ nullable: true }),
    (0, typeorm_1.Column)({ nullable: true }),
    __metadata("design:type", String)
], Organization.prototype, "legalId", void 0);
__decorate([
    (0, graphql_1.Field)({ nullable: true }),
    (0, typeorm_1.Column)({ type: 'text', nullable: true }),
    __metadata("design:type", String)
], Organization.prototype, "description", void 0);
__decorate([
    (0, graphql_1.Field)({ nullable: true }),
    (0, typeorm_1.Column)({ nullable: true }),
    __metadata("design:type", String)
], Organization.prototype, "email", void 0);
__decorate([
    (0, graphql_1.Field)({ nullable: true }),
    (0, typeorm_1.Column)({ nullable: true }),
    __metadata("design:type", String)
], Organization.prototype, "phone", void 0);
__decorate([
    (0, graphql_1.Field)({ nullable: true }),
    (0, typeorm_1.Column)({ nullable: true }),
    __metadata("design:type", String)
], Organization.prototype, "website", void 0);
__decorate([
    (0, graphql_1.Field)({ nullable: true }),
    (0, typeorm_1.Column)({ nullable: true }),
    __metadata("design:type", String)
], Organization.prototype, "address", void 0);
__decorate([
    (0, graphql_1.Field)({ nullable: true }),
    (0, typeorm_1.Column)({ nullable: true }),
    __metadata("design:type", String)
], Organization.prototype, "country", void 0);
__decorate([
    (0, graphql_1.Field)({ nullable: true }),
    (0, typeorm_1.Column)({ nullable: true }),
    __metadata("design:type", String)
], Organization.prototype, "province", void 0);
__decorate([
    (0, graphql_1.Field)({ nullable: true }),
    (0, typeorm_1.Column)({ nullable: true }),
    __metadata("design:type", String)
], Organization.prototype, "canton", void 0);
__decorate([
    (0, graphql_1.Field)({ nullable: true }),
    (0, typeorm_1.Column)({ nullable: true }),
    __metadata("design:type", String)
], Organization.prototype, "district", void 0);
__decorate([
    (0, graphql_1.Field)(() => String),
    (0, typeorm_1.Column)({
        type: 'enum',
        enum: OrganizationStatus,
        default: OrganizationStatus.PENDING_VERIFICATION,
    }),
    __metadata("design:type", String)
], Organization.prototype, "status", void 0);
__decorate([
    (0, typeorm_1.Column)({ type: 'bytea', nullable: true }),
    __metadata("design:type", Object)
], Organization.prototype, "legalDocumentation", void 0);
__decorate([
    (0, graphql_1.Field)(() => String, { nullable: true }),
    __metadata("design:type", Object)
], Organization.prototype, "legalDocumentationBase64", void 0);
__decorate([
    (0, typeorm_1.Column)({ type: 'bytea', nullable: true }),
    __metadata("design:type", Object)
], Organization.prototype, "financialStatements", void 0);
__decorate([
    (0, graphql_1.Field)(() => String, { nullable: true }),
    __metadata("design:type", Object)
], Organization.prototype, "financialStatementsBase64", void 0);
__decorate([
    (0, graphql_1.Field)({ nullable: true }),
    (0, typeorm_1.Column)({ type: 'uuid', nullable: true }),
    __metadata("design:type", String)
], Organization.prototype, "legalRepresentativeId", void 0);
__decorate([
    (0, graphql_1.Field)(),
    (0, typeorm_1.Column)({ default: 0 }),
    __metadata("design:type", Number)
], Organization.prototype, "memberCount", void 0);
__decorate([
    (0, graphql_1.Field)(),
    (0, typeorm_1.Column)({ default: 0 }),
    __metadata("design:type", Number)
], Organization.prototype, "maxCapacity", void 0);
__decorate([
    (0, graphql_1.Field)(),
    (0, typeorm_1.Column)({ default: true }),
    __metadata("design:type", Boolean)
], Organization.prototype, "isActive", void 0);
__decorate([
    (0, graphql_1.Field)(),
    (0, typeorm_1.Column)({ default: false }),
    __metadata("design:type", Boolean)
], Organization.prototype, "isVerified", void 0);
__decorate([
    (0, typeorm_1.OneToMany)(() => organization_membership_entity_1.OrganizationMembership, (membership) => membership.organization),
    __metadata("design:type", Array)
], Organization.prototype, "memberships", void 0);
__decorate([
    (0, graphql_1.Field)(),
    (0, typeorm_1.CreateDateColumn)(),
    __metadata("design:type", Date)
], Organization.prototype, "createdAt", void 0);
__decorate([
    (0, graphql_1.Field)(),
    (0, typeorm_1.UpdateDateColumn)(),
    __metadata("design:type", Date)
], Organization.prototype, "updatedAt", void 0);
exports.Organization = Organization = __decorate([
    (0, graphql_1.ObjectType)(),
    (0, typeorm_1.Entity)('organizations')
], Organization);
//# sourceMappingURL=organization.entity.js.map
