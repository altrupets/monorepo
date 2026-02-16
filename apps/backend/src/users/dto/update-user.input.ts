import { InputType, Field } from '@nestjs/graphql';
import { IsOptional, IsString, MaxLength } from 'class-validator';

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
    @MaxLength(8_000_000)
    avatarBase64?: string;
}
