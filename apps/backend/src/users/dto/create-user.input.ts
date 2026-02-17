import { InputType, Field } from '@nestjs/graphql';
import { IsString, MinLength, IsOptional, IsArray, IsBoolean, IsEnum } from 'class-validator';
import { UserRole } from '../../auth/roles/user-role.enum';

@InputType()
export class CreateUserInput {
  @Field()
  @IsString()
  username: string;

  @Field()
  @IsString()
  @MinLength(8)
  password: string;

  @Field({ nullable: true })
  @IsOptional()
  @IsString()
  firstName?: string;

  @Field({ nullable: true })
  @IsOptional()
  @IsString()
  lastName?: string;

  @Field(() => [String], { nullable: true })
  @IsOptional()
  @IsArray()
  @IsEnum(UserRole, { each: true })
  roles?: UserRole[];

  @Field({ nullable: true })
  @IsOptional()
  @IsBoolean()
  isActive?: boolean;
}
