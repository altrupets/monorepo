import { OrganizationType } from '../entities/organization.entity';
export declare class RegisterOrganizationInput {
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
    legalDocumentationBase64?: string;
    financialStatementsBase64?: string;
    maxCapacity?: number;
}
