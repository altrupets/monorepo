import { InputType, Field, Float, Int } from '@nestjs/graphql';
import { IsNotEmpty, IsOptional, IsString, IsBoolean, IsNumber, Min, Max } from 'class-validator';

@InputType()
export class CreateVetProfileInput {
  @Field()
  @IsNotEmpty()
  @IsString()
  clinicName: string;

  @Field({ nullable: true })
  @IsOptional()
  @IsString()
  licenseNumber?: string;

  @Field({ nullable: true })
  @IsOptional()
  @IsString()
  description?: string;

  @Field({ nullable: true })
  @IsOptional()
  @IsString()
  phone?: string;

  @Field({ nullable: true })
  @IsOptional()
  @IsString()
  email?: string;

  @Field({ nullable: true })
  @IsOptional()
  @IsString()
  website?: string;

  @Field({ nullable: true })
  @IsOptional()
  @IsString()
  address?: string;

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
  openingHours?: string;

  @Field({ nullable: true })
  @IsOptional()
  @IsString()
  services?: string;
}

@InputType()
export class UpdateVetProfileInput {
  @Field({ nullable: true })
  @IsOptional()
  @IsString()
  clinicName?: string;

  @Field({ nullable: true })
  @IsOptional()
  @IsString()
  licenseNumber?: string;

  @Field({ nullable: true })
  @IsOptional()
  @IsString()
  description?: string;

  @Field({ nullable: true })
  @IsOptional()
  @IsString()
  phone?: string;

  @Field({ nullable: true })
  @IsOptional()
  @IsString()
  email?: string;

  @Field({ nullable: true })
  @IsOptional()
  @IsString()
  website?: string;

  @Field({ nullable: true })
  @IsOptional()
  @IsString()
  address?: string;

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

  @Field(() => Float, { nullable: true })
  @IsOptional()
  @IsNumber()
  latitude?: number;

  @Field(() => Float, { nullable: true })
  @IsOptional()
  @IsNumber()
  longitude?: number;

  @Field({ nullable: true })
  @IsOptional()
  @IsString()
  openingHours?: string;

  @Field({ nullable: true })
  @IsOptional()
  @IsString()
  services?: string;

  @Field({ nullable: true })
  @IsOptional()
  @IsBoolean()
  isActive?: boolean;
}
