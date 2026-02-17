import { Repository } from 'typeorm';
import { Organization } from './entities/organization.entity';
import { OrganizationMembership } from './entities/organization-membership.entity';
import { RegisterOrganizationInput } from './dto/register-organization.input';
import { RequestMembershipInput } from './dto/request-membership.input';
import { ApproveMembershipInput, RejectMembershipInput, AssignRoleInput } from './dto/manage-membership.input';
import { SearchOrganizationsInput } from './dto/search-organizations.input';
export declare class OrganizationsService {
    private organizationsRepository;
    private membershipsRepository;
    constructor(organizationsRepository: Repository<Organization>, membershipsRepository: Repository<OrganizationMembership>);
    registerOrganization(input: RegisterOrganizationInput, userId: string): Promise<Organization>;
    searchOrganizations(input: SearchOrganizationsInput): Promise<Organization[]>;
    getOrganizationById(id: string): Promise<Organization>;
    requestMembership(input: RequestMembershipInput, userId: string): Promise<OrganizationMembership>;
    approveMembership(input: ApproveMembershipInput, approverId: string): Promise<OrganizationMembership>;
    rejectMembership(input: RejectMembershipInput, rejecterId: string): Promise<OrganizationMembership>;
    assignRole(input: AssignRoleInput, assignerId: string): Promise<OrganizationMembership>;
    getOrganizationMemberships(organizationId: string): Promise<OrganizationMembership[]>;
    getUserMemberships(userId: string): Promise<OrganizationMembership[]>;
    private checkAdminPermission;
    private checkLegalRepPermission;
}
