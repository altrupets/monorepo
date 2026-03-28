import { InputType, Field, ID, Float, Int } from '@nestjs/graphql';
import { IsUUID, IsOptional, IsNumber, IsString, IsInt, Min, Max } from 'class-validator';

@InputType()
export class MatchingInput {
  @Field(() => ID)
  @IsUUID()
  rescueAlertId: string;

  @Field(() => Float, { nullable: true })
  @IsNumber()
  @IsOptional()
  latitude?: number;

  @Field(() => Float, { nullable: true })
  @IsNumber()
  @IsOptional()
  longitude?: number;

  @Field({ nullable: true })
  @IsString()
  @IsOptional()
  urgency?: string;

  @Field({ nullable: true })
  @IsString()
  @IsOptional()
  animalType?: string;

  @Field(() => Int, { nullable: true })
  @IsInt()
  @Min(1)
  @Max(20)
  @IsOptional()
  maxCandidates?: number;
}
