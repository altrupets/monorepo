import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { OrganizationsService } from './organizations.service';
import { OrganizationsResolver } from './organizations.resolver';
import { Organization } from './entities/organization.entity';
import { OrganizationMembership } from './entities/organization-membership.entity';
import './enums/organization.enums'; // Register GraphQL enums

@Module({
  imports: [TypeOrmModule.forFeature([Organization, OrganizationMembership])],
  providers: [OrganizationsService, OrganizationsResolver],
  exports: [OrganizationsService],
})
export class OrganizationsModule {}
