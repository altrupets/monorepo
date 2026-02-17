import { OrganizationRole } from '../entities/organization-membership.entity';
export declare class ApproveMembershipInput {
    membershipId: string;
    role?: OrganizationRole;
}
export declare class RejectMembershipInput {
    membershipId: string;
    rejectionReason?: string;
}
export declare class AssignRoleInput {
    membershipId: string;
    role: OrganizationRole;
}
