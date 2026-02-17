import { InputType, Field, Float } from '@nestjs/graphql';
import { IsOptional, IsString, MaxLength, IsNumber, Min, Max, IsArray, IsBoolean, IsEnum } from 'class-validator';
import { UserRole } from '../../auth/roles/user-role.enum';

@InputType()
export class UpdateUserInput {
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

    @Field(() => Float, { nullable: true })
    @IsOptional()
    @IsNumber()
    @Min(-90)
    @Max(90)
    latitude?: number;

    @Field(() => Float, { nullable: true })
    @IsOptional()
    @IsNumber()
    @Min(-180)
    @Max(180)
    longitude?: number;

    @Field({ nullable: true })
    @IsOptional()
    @IsString()
    @MaxLength(8_000_000)
    avatarBase64?: string;

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
