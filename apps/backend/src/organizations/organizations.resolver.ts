import { Resolver, Query, Mutation, Args, ID } from '@nestjs/graphql';
import { UseGuards } from '@nestjs/common';
import { OrganizationsService } from './organizations.service';
import { Organization } from './entities/organization.entity';
import { OrganizationMembership } from './entities/organization-membership.entity';
import { RegisterOrganizationInput } from './dto/register-organization.input';
import { RequestMembershipInput } from './dto/request-membership.input';
import {
  ApproveMembershipInput,
  RejectMembershipInput,
  AssignRoleInput,
} from './dto/manage-membership.input';
import { SearchOrganizationsInput } from './dto/search-organizations.input';
import { JwtAuthGuard } from '../auth/jwt-auth.guard';
import { GqlUser } from '../auth/gql-user.decorator';
import { User } from '../users/entities/user.entity';

@Resolver(() => Organization)
export class OrganizationsResolver {
  constructor(private readonly organizationsService: OrganizationsService) {}

  @Mutation(() => Organization)
  @UseGuards(JwtAuthGuard)
  async registerOrganization(
    @Args('registerOrganizationInput')
    registerOrganizationInput: RegisterOrganizationInput,
    @GqlUser() user: User,
  ): Promise<Organization> {
    return this.organizationsService.registerOrganization(
      registerOrganizationInput,
      user.id,
    );
  }

  @Query(() => [Organization])
  async searchOrganizations(
    @Args('searchOrganizationsInput')
    searchOrganizationsInput: SearchOrganizationsInput,
  ): Promise<Organization[]> {
    return this.organizationsService.searchOrganizations(
      searchOrganizationsInput,
    );
  }

  @Query(() => Organization)
  async organization(
    @Args('id', { type: () => ID }) id: string,
  ): Promise<Organization> {
    return this.organizationsService.getOrganizationById(id);
  }

  @Mutation(() => OrganizationMembership)
  @UseGuards(JwtAuthGuard)
  async requestMembership(
    @Args('requestMembershipInput')
    requestMembershipInput: RequestMembershipInput,
    @GqlUser() user: User,
  ): Promise<OrganizationMembership> {
    return this.organizationsService.requestMembership(
      requestMembershipInput,
      user.id,
    );
  }

  @Mutation(() => OrganizationMembership)
  @UseGuards(JwtAuthGuard)
  async approveMembership(
    @Args('approveMembershipInput')
    approveMembershipInput: ApproveMembershipInput,
    @GqlUser() user: User,
  ): Promise<OrganizationMembership> {
    return this.organizationsService.approveMembership(
      approveMembershipInput,
      user.id,
    );
  }

  @Mutation(() => OrganizationMembership)
  @UseGuards(JwtAuthGuard)
  async rejectMembership(
    @Args('rejectMembershipInput')
    rejectMembershipInput: RejectMembershipInput,
    @GqlUser() user: User,
  ): Promise<OrganizationMembership> {
    return this.organizationsService.rejectMembership(
      rejectMembershipInput,
      user.id,
    );
  }

  @Mutation(() => OrganizationMembership)
  @UseGuards(JwtAuthGuard)
  async assignRole(
    @Args('assignRoleInput') assignRoleInput: AssignRoleInput,
    @GqlUser() user: User,
  ): Promise<OrganizationMembership> {
    return this.organizationsService.assignRole(assignRoleInput, user.id);
  }

  @Query(() => [OrganizationMembership])
  @UseGuards(JwtAuthGuard)
  async organizationMemberships(
    @Args('organizationId', { type: () => ID }) organizationId: string,
  ): Promise<OrganizationMembership[]> {
    return this.organizationsService.getOrganizationMemberships(
      organizationId,
    );
  }

  @Query(() => [OrganizationMembership])
  @UseGuards(JwtAuthGuard)
  async myMemberships(@GqlUser() user: User): Promise<OrganizationMembership[]> {
    return this.organizationsService.getUserMemberships(user.id);
  }
}
