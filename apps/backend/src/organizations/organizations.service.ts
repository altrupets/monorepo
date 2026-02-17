import { Injectable, NotFoundException, BadRequestException, ForbiddenException } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository, Like } from 'typeorm';
import { Organization, OrganizationStatus } from './entities/organization.entity';
import { OrganizationMembership, MembershipStatus, OrganizationRole } from './entities/organization-membership.entity';
import { RegisterOrganizationInput } from './dto/register-organization.input';
import { RequestMembershipInput } from './dto/request-membership.input';
import { ApproveMembershipInput, RejectMembershipInput, AssignRoleInput } from './dto/manage-membership.input';
import { SearchOrganizationsInput } from './dto/search-organizations.input';
import { UserRole } from '../auth/roles/user-role.enum';

@Injectable()
export class OrganizationsService {
  constructor(
    @InjectRepository(Organization)
    private organizationsRepository: Repository<Organization>,
    @InjectRepository(OrganizationMembership)
    private membershipsRepository: Repository<OrganizationMembership>,
  ) {}

  async registerOrganization(
    input: RegisterOrganizationInput,
    userId: string,
  ): Promise<Organization> {
    // Check if organization name already exists
    const existing = await this.organizationsRepository.findOne({
      where: { name: input.name },
    });

    if (existing) {
      throw new BadRequestException('Organization name already exists');
    }

    // Create organization
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
      status: OrganizationStatus.PENDING_VERIFICATION,
      isActive: true,
      isVerified: false,
      memberCount: 1,
    });

    // Handle legal documentation
    if (input.legalDocumentationBase64) {
      organization.legalDocumentation = Buffer.from(
        input.legalDocumentationBase64,
        'base64',
      );
    }

    // Handle financial statements
    if (input.financialStatementsBase64) {
      organization.financialStatements = Buffer.from(
        input.financialStatementsBase64,
        'base64',
      );
    }

    const savedOrg = await this.organizationsRepository.save(organization);

    // Create membership for legal representative (REQ-ADM-001)
    const membership = this.membershipsRepository.create({
      organizationId: savedOrg.id,
      userId: userId,
      status: MembershipStatus.APPROVED,
      role: OrganizationRole.LEGAL_REPRESENTATIVE,
      approvedBy: userId,
      approvedAt: new Date(),
    });

    await this.membershipsRepository.save(membership);

    return savedOrg;
  }

  async searchOrganizations(
    input: SearchOrganizationsInput,
  ): Promise<Organization[]> {
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

  async getOrganizationById(id: string): Promise<Organization> {
    const organization = await this.organizationsRepository.findOne({
      where: { id },
    });

    if (!organization) {
      throw new NotFoundException('Organization not found');
    }

    // Convert binary data to base64 for GraphQL response
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

  async requestMembership(
    input: RequestMembershipInput,
    userId: string,
  ): Promise<OrganizationMembership> {
    // Check if organization exists
    const organization = await this.organizationsRepository.findOne({
      where: { id: input.organizationId },
    });

    if (!organization) {
      throw new NotFoundException('Organization not found');
    }

    // Check if user already has a membership
    const existing = await this.membershipsRepository.findOne({
      where: {
        organizationId: input.organizationId,
        userId: userId,
      },
    });

    if (existing) {
      throw new BadRequestException('Membership request already exists');
    }

    // Create membership request
    const membership = this.membershipsRepository.create({
      organizationId: input.organizationId,
      userId: userId,
      status: MembershipStatus.PENDING,
      role: OrganizationRole.MEMBER,
      requestMessage: input.requestMessage,
    });

    return this.membershipsRepository.save(membership);
  }

  async approveMembership(
    input: ApproveMembershipInput,
    approverId: string,
  ): Promise<OrganizationMembership> {
    const membership = await this.membershipsRepository.findOne({
      where: { id: input.membershipId },
      relations: ['organization'],
    });

    if (!membership) {
      throw new NotFoundException('Membership not found');
    }

    // Check if approver has permission (must be LEGAL_REPRESENTATIVE or USER_ADMIN)
    await this.checkAdminPermission(membership.organizationId, approverId);

    // Update membership
    membership.status = MembershipStatus.APPROVED;
    membership.role = input.role || OrganizationRole.MEMBER;
    membership.approvedBy = approverId;
    membership.approvedAt = new Date();

    const saved = await this.membershipsRepository.save(membership);

    // Update organization member count
    await this.organizationsRepository.increment(
      { id: membership.organizationId },
      'memberCount',
      1,
    );

    return saved;
  }

  async rejectMembership(
    input: RejectMembershipInput,
    rejecterId: string,
  ): Promise<OrganizationMembership> {
    const membership = await this.membershipsRepository.findOne({
      where: { id: input.membershipId },
    });

    if (!membership) {
      throw new NotFoundException('Membership not found');
    }

    // Check if rejecter has permission
    await this.checkAdminPermission(membership.organizationId, rejecterId);

    membership.status = MembershipStatus.REJECTED;
    membership.rejectionReason = input.rejectionReason;

    return this.membershipsRepository.save(membership);
  }

  async assignRole(
    input: AssignRoleInput,
    assignerId: string,
  ): Promise<OrganizationMembership> {
    const membership = await this.membershipsRepository.findOne({
      where: { id: input.membershipId },
    });

    if (!membership) {
      throw new NotFoundException('Membership not found');
    }

    // Check if assigner has permission (must be LEGAL_REPRESENTATIVE)
    await this.checkLegalRepPermission(membership.organizationId, assignerId);

    membership.role = input.role;

    return this.membershipsRepository.save(membership);
  }

  async getOrganizationMemberships(
    organizationId: string,
  ): Promise<OrganizationMembership[]> {
    return this.membershipsRepository.find({
      where: { organizationId },
      relations: ['user'],
    });
  }

  async getUserMemberships(userId: string): Promise<OrganizationMembership[]> {
    return this.membershipsRepository.find({
      where: { userId },
      relations: ['organization'],
    });
  }

  private async checkAdminPermission(
    organizationId: string,
    userId: string,
  ): Promise<void> {
    const membership = await this.membershipsRepository.findOne({
      where: {
        organizationId,
        userId,
        status: MembershipStatus.APPROVED,
      },
    });

    if (
      !membership ||
      (membership.role !== OrganizationRole.LEGAL_REPRESENTATIVE &&
        membership.role !== OrganizationRole.USER_ADMIN)
    ) {
      throw new ForbiddenException(
        'Only Legal Representative or User Admin can perform this action',
      );
    }
  }

  private async checkLegalRepPermission(
    organizationId: string,
    userId: string,
  ): Promise<void> {
    const membership = await this.membershipsRepository.findOne({
      where: {
        organizationId,
        userId,
        status: MembershipStatus.APPROVED,
      },
    });

    if (
      !membership ||
      membership.role !== OrganizationRole.LEGAL_REPRESENTATIVE
    ) {
      throw new ForbiddenException(
        'Only Legal Representative can perform this action',
      );
    }
  }
}
