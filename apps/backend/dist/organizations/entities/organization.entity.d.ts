import { OrganizationMembership } from './organization-membership.entity';
export declare enum OrganizationType {
    FOUNDATION = "FOUNDATION",
    ASSOCIATION = "ASSOCIATION",
    NGO = "NGO",
    COOPERATIVE = "COOPERATIVE",
    GOVERNMENT = "GOVERNMENT",
    OTHER = "OTHER"
}
export declare enum OrganizationStatus {
    PENDING_VERIFICATION = "PENDING_VERIFICATION",
    ACTIVE = "ACTIVE",
    SUSPENDED = "SUSPENDED",
    INACTIVE = "INACTIVE"
}
export declare class Organization {
    id: string;
    name: string;
    type: OrganizationType;
    legalId?: string;
    description?: string;
    email?: string;
    phone?: string;
    website?: string;
    address?: string;
    country?: string;
    province?: string;
    canton?: string;
    district?: string;
    status: OrganizationStatus;
    legalDocumentation?: Buffer | null;
    legalDocumentationBase64?: string | null;
    financialStatements?: Buffer | null;
    financialStatementsBase64?: string | null;
    legalRepresentativeId?: string;
    memberCount: number;
    maxCapacity: number;
    isActive: boolean;
    isVerified: boolean;
    memberships: OrganizationMembership[];
    createdAt: Date;
    updatedAt: Date;
}
