import { InputType, Field } from '@nestjs/graphql';
import { IsString, IsEmail, IsOptional, MinLength, IsEnum } from 'class-validator';
import { OrganizationType } from '../entities/organization.entity';

@InputType()
export class RegisterOrganizationInput {
  @Field()
  @IsString()
  @MinLength(3)
  name: string;

  @Field(() => String)
  @IsEnum(OrganizationType)
  type: OrganizationType;

  @Field({ nullable: true })
  @IsString()
  @IsOptional()
  legalId?: string;

  @Field({ nullable: true })
  @IsString()
  @IsOptional()
  description?: string;

  @Field({ nullable: true })
  @IsEmail()
  @IsOptional()
  email?: string;

  @Field({ nullable: true })
  @IsString()
  @IsOptional()
  phone?: string;

  @Field({ nullable: true })
  @IsString()
  @IsOptional()
  website?: string;

  @Field({ nullable: true })
  @IsString()
  @IsOptional()
  address?: string;

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

  @Field({ nullable: true })
  @IsString()
  @IsOptional()
  district?: string;

  @Field({ nullable: true })
  @IsString()
  @IsOptional()
  legalDocumentationBase64?: string;

  @Field({ nullable: true })
  @IsString()
  @IsOptional()
  financialStatementsBase64?: string;

  @Field({ nullable: true })
  @IsString()
  @IsOptional()
  maxCapacity?: number;
}
