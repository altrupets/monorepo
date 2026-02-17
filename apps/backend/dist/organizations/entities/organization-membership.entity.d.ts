import { Organization } from './organization.entity';
import { User } from '../../users/entities/user.entity';
export declare enum MembershipStatus {
    PENDING = "PENDING",
    APPROVED = "APPROVED",
    REJECTED = "REJECTED",
    REVOKED = "REVOKED"
}
export declare enum OrganizationRole {
    LEGAL_REPRESENTATIVE = "LEGAL_REPRESENTATIVE",
    USER_ADMIN = "USER_ADMIN",
    MEMBER = "MEMBER"
}
export declare class OrganizationMembership {
    id: string;
    organizationId: string;
    organization: Organization;
    userId: string;
    user: User;
    status: MembershipStatus;
    role: OrganizationRole;
    requestMessage?: string;
    rejectionReason?: string;
    approvedBy?: string;
    approvedAt?: Date;
    createdAt: Date;
    updatedAt: Date;
}
