import { InputType, Field, ID } from '@nestjs/graphql';
import { IsNotEmpty, IsString, IsUUID } from 'class-validator';

@InputType()
export class CompleteRescueInput {
  @Field(() => ID)
  @IsUUID()
  @IsNotEmpty()
  alertId: string;

  @Field()
  @IsString()
  @IsNotEmpty()
  animalName: string;

  @Field()
  @IsString()
  @IsNotEmpty()
  species: string;

  @Field(() => ID)
  @IsUUID()
  @IsNotEmpty()
  casaCunaId: string;
}
