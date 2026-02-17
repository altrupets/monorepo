import { registerEnumType } from '@nestjs/graphql';
import { OrganizationType, OrganizationStatus } from '../entities/organization.entity';
import { MembershipStatus, OrganizationRole } from '../entities/organization-membership.entity';

// Register GraphQL enums
registerEnumType(OrganizationType, {
  name: 'OrganizationType',
  description: 'Type of organization',
});

registerEnumType(OrganizationStatus, {
  name: 'OrganizationStatus',
  description: 'Status of organization',
});

registerEnumType(MembershipStatus, {
  name: 'MembershipStatus',
  description: 'Status of membership request',
});

registerEnumType(OrganizationRole, {
  name: 'OrganizationRole',
  description: 'Role within organization',
});
