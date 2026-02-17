import { OrganizationType, OrganizationStatus } from '../entities/organization.entity';
export declare class SearchOrganizationsInput {
    name?: string;
    type?: OrganizationType;
    status?: OrganizationStatus;
    country?: string;
    province?: string;
    canton?: string;
}
