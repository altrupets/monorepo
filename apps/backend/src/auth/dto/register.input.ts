import { InputType, Field } from '@nestjs/graphql';
import { IsString, IsNotEmpty, MinLength, IsOptional, IsEmail } from 'class-validator';
import { UserRole } from '../roles/user-role.enum';

@InputType()
export class RegisterInput {
  @Field()
  @IsString()
  @IsNotEmpty()
  @MinLength(3)
  username: string;

  @Field({ nullable: true })
  @IsOptional()
  @IsEmail()
  email?: string;

  @Field()
  @IsString()
  @IsNotEmpty()
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

  @Field({ nullable: true })
  @IsOptional()
  @IsString()
  phone?: string;

  @Field({ nullable: true })
  @IsOptional()
  @IsString()
  identification?: string;

  @Field({ nullable: true })
  @IsOptional()
  @IsString()
  country?: string;

  @Field({ nullable: true })
  @IsOptional()
  @IsString()
  province?: string;

  @Field({ nullable: true })
  @IsOptional()
  @IsString()
  canton?: string;

  @Field({ nullable: true })
  @IsOptional()
  @IsString()
  district?: string;

  @Field({ nullable: true })
  @IsOptional()
  @IsString()
  occupation?: string;

  @Field({ nullable: true })
  @IsOptional()
  @IsString()
  incomeSource?: string;

  @Field(() => [UserRole], { nullable: true })
  @IsOptional()
  roles?: UserRole[];
}
