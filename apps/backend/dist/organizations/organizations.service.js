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
exports.OrganizationsService = void 0;
const common_1 = require("@nestjs/common");
const typeorm_1 = require("@nestjs/typeorm");
const typeorm_2 = require("typeorm");
const organization_entity_1 = require("./entities/organization.entity");
const organization_membership_entity_1 = require("./entities/organization-membership.entity");
let OrganizationsService = class OrganizationsService {
    organizationsRepository;
    membershipsRepository;
    constructor(organizationsRepository, membershipsRepository) {
        this.organizationsRepository = organizationsRepository;
        this.membershipsRepository = membershipsRepository;
    }
    async registerOrganization(input, userId) {
        const existing = await this.organizationsRepository.findOne({
            where: { name: input.name },
        });
        if (existing) {
            throw new common_1.BadRequestException('Organization name already exists');
        }
        const organization = this.organizationsRepository.create({
            name: input.name,
            type: input.type,
            legalId: input.legalId,
            description: input.description,
            email: input.email,
            phone: input.phone,
            website: input.website,
            address: input.address,
            country: input.country,
            province: input.province,
            canton: input.canton,
            district: input.district,
            maxCapacity: input.maxCapacity || 0,
            legalRepresentativeId: userId,
            status: organization_entity_1.OrganizationStatus.PENDING_VERIFICATION,
            isActive: true,
            isVerified: false,
            memberCount: 1,
        });
        if (input.legalDocumentationBase64) {
            organization.legalDocumentation = Buffer.from(input.legalDocumentationBase64, 'base64');
        }
        if (input.financialStatementsBase64) {
            organization.financialStatements = Buffer.from(input.financialStatementsBase64, 'base64');
        }
        const savedOrg = await this.organizationsRepository.save(organization);
        const membership = this.membershipsRepository.create({
            organizationId: savedOrg.id,
            userId: userId,
            status: organization_membership_entity_1.MembershipStatus.APPROVED,
            role: organization_membership_entity_1.OrganizationRole.LEGAL_REPRESENTATIVE,
            approvedBy: userId,
            approvedAt: new Date(),
        });
        await this.membershipsRepository.save(membership);
        return savedOrg;
    }
    async searchOrganizations(input) {
        const query = this.organizationsRepository.createQueryBuilder('org');
        if (input.name) {
            query.andWhere('org.name ILIKE :name', { name: `%${input.name}%` });
        }
        if (input.type) {
            query.andWhere('org.type = :type', { type: input.type });
        }
        if (input.status) {
            query.andWhere('org.status = :status', { status: input.status });
        }
        if (input.country) {
            query.andWhere('org.country = :country', { country: input.country });
        }
        if (input.province) {
            query.andWhere('org.province = :province', { province: input.province });
        }
        if (input.canton) {
            query.andWhere('org.canton = :canton', { canton: input.canton });
        }
        query.andWhere('org.isActive = :isActive', { isActive: true });
        return query.getMany();
    }
    async getOrganizationById(id) {
        const organization = await this.organizationsRepository.findOne({
            where: { id },
        });
        if (!organization) {
            throw new common_1.NotFoundException('Organization not found');
        }
        if (organization.legalDocumentation) {
            organization.legalDocumentationBase64 =
                organization.legalDocumentation.toString('base64');
        }
        if (organization.financialStatements) {
            organization.financialStatementsBase64 =
                organization.financialStatements.toString('base64');
        }
        return organization;
    }
    async requestMembership(input, userId) {
        const organization = await this.organizationsRepository.findOne({
            where: { id: input.organizationId },
        });
        if (!organization) {
            throw new common_1.NotFoundException('Organization not found');
        }
        const existing = await this.membershipsRepository.findOne({
            where: {
                organizationId: input.organizationId,
                userId: userId,
            },
        });
        if (existing) {
            throw new common_1.BadRequestException('Membership request already exists');
        }
        const membership = this.membershipsRepository.create({
            organizationId: input.organizationId,
            userId: userId,
            status: organization_membership_entity_1.MembershipStatus.PENDING,
            role: organization_membership_entity_1.OrganizationRole.MEMBER,
            requestMessage: input.requestMessage,
        });
        return this.membershipsRepository.save(membership);
    }
    async approveMembership(input, approverId) {
        const membership = await this.membershipsRepository.findOne({
            where: { id: input.membershipId },
            relations: ['organization'],
        });
        if (!membership) {
            throw new common_1.NotFoundException('Membership not found');
        }
        await this.checkAdminPermission(membership.organizationId, approverId);
        membership.status = organization_membership_entity_1.MembershipStatus.APPROVED;
        membership.role = input.role || organization_membership_entity_1.OrganizationRole.MEMBER;
        membership.approvedBy = approverId;
        membership.approvedAt = new Date();
        const saved = await this.membershipsRepository.save(membership);
        await this.organizationsRepository.increment({ id: membership.organizationId }, 'memberCount', 1);
        return saved;
    }
    async rejectMembership(input, rejecterId) {
        const membership = await this.membershipsRepository.findOne({
            where: { id: input.membershipId },
        });
        if (!membership) {
            throw new common_1.NotFoundException('Membership not found');
        }
        await this.checkAdminPermission(membership.organizationId, rejecterId);
        membership.status = organization_membership_entity_1.MembershipStatus.REJECTED;
        membership.rejectionReason = input.rejectionReason;
        return this.membershipsRepository.save(membership);
    }
    async assignRole(input, assignerId) {
        const membership = await this.membershipsRepository.findOne({
            where: { id: input.membershipId },
        });
        if (!membership) {
            throw new common_1.NotFoundException('Membership not found');
        }
        await this.checkLegalRepPermission(membership.organizationId, assignerId);
        membership.role = input.role;
        return this.membershipsRepository.save(membership);
    }
    async getOrganizationMemberships(organizationId) {
        return this.membershipsRepository.find({
            where: { organizationId },
            relations: ['user'],
        });
    }
    async getUserMemberships(userId) {
        return this.membershipsRepository.find({
            where: { userId },
            relations: ['organization'],
        });
    }
    async checkAdminPermission(organizationId, userId) {
        const membership = await this.membershipsRepository.findOne({
            where: {
                organizationId,
                userId,
                status: organization_membership_entity_1.MembershipStatus.APPROVED,
            },
        });
        if (!membership ||
            (membership.role !== organization_membership_entity_1.OrganizationRole.LEGAL_REPRESENTATIVE &&
                membership.role !== organization_membership_entity_1.OrganizationRole.USER_ADMIN)) {
            throw new common_1.ForbiddenException('Only Legal Representative or User Admin can perform this action');
        }
    }
    async checkLegalRepPermission(organizationId, userId) {
        const membership = await this.membershipsRepository.findOne({
            where: {
                organizationId,
                userId,
                status: organization_membership_entity_1.MembershipStatus.APPROVED,
            },
        });
        if (!membership ||
            membership.role !== organization_membership_entity_1.OrganizationRole.LEGAL_REPRESENTATIVE) {
            throw new common_1.ForbiddenException('Only Legal Representative can perform this action');
        }
    }
};
exports.OrganizationsService = OrganizationsService;
exports.OrganizationsService = OrganizationsService = __decorate([
    (0, common_1.Injectable)(),
    __param(0, (0, typeorm_1.InjectRepository)(organization_entity_1.Organization)),
    __param(1, (0, typeorm_1.InjectRepository)(organization_membership_entity_1.OrganizationMembership)),
    __metadata("design:paramtypes", [typeorm_2.Repository,
        typeorm_2.Repository])
], OrganizationsService);
//# sourceMappingURL=organizations.service.js.map
