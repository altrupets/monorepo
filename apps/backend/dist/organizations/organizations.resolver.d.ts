import { OrganizationsService } from './organizations.service';
import { Organization } from './entities/organization.entity';
import { OrganizationMembership } from './entities/organization-membership.entity';
import { RegisterOrganizationInput } from './dto/register-organization.input';
import { RequestMembershipInput } from './dto/request-membership.input';
import { ApproveMembershipInput, RejectMembershipInput, AssignRoleInput } from './dto/manage-membership.input';
import { SearchOrganizationsInput } from './dto/search-organizations.input';
import { User } from '../users/entities/user.entity';
export declare class OrganizationsResolver {
    private readonly organizationsService;
    constructor(organizationsService: OrganizationsService);
    registerOrganization(registerOrganizationInput: RegisterOrganizationInput, user: User): Promise<Organization>;
    searchOrganizations(searchOrganizationsInput: SearchOrganizationsInput): Promise<Organization[]>;
    organization(id: string): Promise<Organization>;
    requestMembership(requestMembershipInput: RequestMembershipInput, user: User): Promise<OrganizationMembership>;
    approveMembership(approveMembershipInput: ApproveMembershipInput, user: User): Promise<OrganizationMembership>;
    rejectMembership(rejectMembershipInput: RejectMembershipInput, user: User): Promise<OrganizationMembership>;
    assignRole(assignRoleInput: AssignRoleInput, user: User): Promise<OrganizationMembership>;
    organizationMemberships(organizationId: string): Promise<OrganizationMembership[]>;
    myMemberships(user: User): Promise<OrganizationMembership[]>;
}
