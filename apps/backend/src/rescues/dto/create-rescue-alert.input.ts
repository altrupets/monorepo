import { InputType, Field, Float } from '@nestjs/graphql';
import { IsNotEmpty, IsNumber, IsOptional, IsString, IsEnum, IsArray } from 'class-validator';
import { RescueUrgency } from '../enums/rescue-urgency.enum';

@InputType()
export class CreateRescueAlertInput {
  @Field(() => Float)
  @IsNumber()
  @IsNotEmpty()
  latitude: number;

  @Field(() => Float)
  @IsNumber()
  @IsNotEmpty()
  longitude: number;

  @Field({ nullable: true })
  @IsString()
  @IsOptional()
  locationDescription?: string;

  @Field(() => RescueUrgency)
  @IsEnum(RescueUrgency)
  @IsNotEmpty()
  urgency: RescueUrgency;

  @Field({ nullable: true })
  @IsString()
  @IsOptional()
  description?: string;

  @Field(() => [String], { nullable: true })
  @IsArray()
  @IsOptional()
  imageBase64s?: string[];

  @Field({ nullable: true })
  @IsString()
  @IsOptional()
  animalType?: string;
}
