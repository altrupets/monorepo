import { InputType, Field, Float, Int } from '@nestjs/graphql';
import { IsNotEmpty, IsOptional, IsString, IsBoolean, IsNumber, Min, Max, IsArray } from 'class-validator';
import { PricingTier } from '../entities/vet-profile.entity';

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

  @Field(() => [String], { nullable: true })
  @IsOptional()
  @IsArray()
  specialties?: string[];

  @Field(() => [String], { nullable: true })
  @IsOptional()
  @IsArray()
  clinicPhotos?: string[];

  @Field(() => PricingTier, { nullable: true })
  @IsOptional()
  pricingTier?: PricingTier;
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

  @Field(() => [String], { nullable: true })
  @IsOptional()
  @IsArray()
  specialties?: string[];

  @Field(() => [String], { nullable: true })
  @IsOptional()
  @IsArray()
  clinicPhotos?: string[];

  @Field(() => PricingTier, { nullable: true })
  @IsOptional()
  pricingTier?: PricingTier;
}
