import { InputType, Field, ID } from '@nestjs/graphql';
import { IsNotEmpty, IsOptional, IsString, IsUUID, IsArray } from 'class-validator';

@InputType()
export class UpdateRescueProgressInput {
  @Field(() => ID)
  @IsUUID()
  @IsNotEmpty()
  alertId: string;

  @Field()
  @IsString()
  @IsNotEmpty()
  conditionAssessment: string;

  @Field(() => [String], { nullable: true })
  @IsArray()
  @IsOptional()
  imageBase64s?: string[];
}
