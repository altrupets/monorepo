"use strict";
var __decorate = (this && this.__decorate) || function (decorators, target, key, desc) {
    var c = arguments.length, r = c < 3 ? target : desc === null ? desc = Object.getOwnPropertyDescriptor(target, key) : desc, d;
    if (typeof Reflect === "object" && typeof Reflect.decorate === "function") r = Reflect.decorate(decorators, target, key, desc);
    else for (var i = decorators.length - 1; i >= 0; i--) if (d = decorators[i]) r = (c < 3 ? d(r) : c > 3 ? d(target, key, r) : d(target, key)) || r;
    return c > 3 && r && Object.defineProperty(target, key, r), r;
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.OrganizationsModule = void 0;
const common_1 = require("@nestjs/common");
const typeorm_1 = require("@nestjs/typeorm");
const organizations_service_1 = require("./organizations.service");
const organizations_resolver_1 = require("./organizations.resolver");
const organization_entity_1 = require("./entities/organization.entity");
const organization_membership_entity_1 = require("./entities/organization-membership.entity");
require("./enums/organization.enums");
let OrganizationsModule = class OrganizationsModule {
};
exports.OrganizationsModule = OrganizationsModule;
exports.OrganizationsModule = OrganizationsModule = __decorate([
    (0, common_1.Module)({
        imports: [typeorm_1.TypeOrmModule.forFeature([organization_entity_1.Organization, organization_membership_entity_1.OrganizationMembership])],
        providers: [organizations_service_1.OrganizationsService, organizations_resolver_1.OrganizationsResolver],
        exports: [organizations_service_1.OrganizationsService],
    })
], OrganizationsModule);
//# sourceMappingURL=organizations.module.js.map
