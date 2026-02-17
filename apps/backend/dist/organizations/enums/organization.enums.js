"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
const graphql_1 = require("@nestjs/graphql");
const organization_entity_1 = require("../entities/organization.entity");
const organization_membership_entity_1 = require("../entities/organization-membership.entity");
(0, graphql_1.registerEnumType)(organization_entity_1.OrganizationType, {
    name: 'OrganizationType',
    description: 'Type of organization',
});
(0, graphql_1.registerEnumType)(organization_entity_1.OrganizationStatus, {
    name: 'OrganizationStatus',
    description: 'Status of organization',
});
(0, graphql_1.registerEnumType)(organization_membership_entity_1.MembershipStatus, {
    name: 'MembershipStatus',
    description: 'Status of membership request',
});
(0, graphql_1.registerEnumType)(organization_membership_entity_1.OrganizationRole, {
    name: 'OrganizationRole',
    description: 'Role within organization',
});
//# sourceMappingURL=organization.enums.js.map