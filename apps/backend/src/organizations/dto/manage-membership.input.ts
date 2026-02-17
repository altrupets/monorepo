import { InputType, Field, ID } from '@nestjs/graphql';
import { IsString, IsUUID, IsOptional, IsEnum } from 'class-validator';
import { OrganizationRole } from '../entities/organization-membership.entity';

@InputType()
export class ApproveMembershipInput {
  @Field(() => ID)
  @IsUUID()
  membershipId: string;

  @Field(() => String, { nullable: true })
  @IsEnum(OrganizationRole)
  @IsOptional()
  role?: OrganizationRole;
}

@InputType()
export class RejectMembershipInput {
  @Field(() => ID)
  @IsUUID()
  membershipId: string;

  @Field({ nullable: true })
  @IsString()
  @IsOptional()
  rejectionReason?: string;
}

@InputType()
export class AssignRoleInput {
  @Field(() => ID)
  @IsUUID()
  membershipId: string;

  @Field(() => String)
  @IsEnum(OrganizationRole)
  role: OrganizationRole;
}
