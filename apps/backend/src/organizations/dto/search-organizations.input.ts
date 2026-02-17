import { InputType, Field } from '@nestjs/graphql';
import { IsString, IsOptional, IsEnum } from 'class-validator';
import { OrganizationType, OrganizationStatus } from '../entities/organization.entity';

@InputType()
export class SearchOrganizationsInput {
  @Field({ nullable: true })
  @IsString()
  @IsOptional()
  name?: string;

  @Field(() => String, { nullable: true })
  @IsEnum(OrganizationType)
  @IsOptional()
  type?: OrganizationType;

  @Field(() => String, { nullable: true })
  @IsEnum(OrganizationStatus)
  @IsOptional()
  status?: OrganizationStatus;

  @Field({ nullable: true })
  @IsString()
  @IsOptional()
  country?: string;

  @Field({ nullable: true })
  @IsString()
  @IsOptional()
  province?: string;

  @Field({ nullable: true })
  @IsString()
  @IsOptional()
  canton?: string;
}
