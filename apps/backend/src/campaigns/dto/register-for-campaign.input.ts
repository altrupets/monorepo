import { InputType, Field, ID } from '@nestjs/graphql';
import { AnimalSpecies, AnimalSex } from '../enums/registration-status.enum';

@InputType()
export class RegisterForCampaignInput {
  @Field(() => ID)
  campaignId: string;

  @Field()
  ownerName: string;

  @Field()
  ownerPhone: string;

  @Field()
  animalName: string;

  @Field(() => AnimalSpecies)
  animalSpecies: AnimalSpecies;

  @Field({ nullable: true })
  animalBreed?: string;

  @Field({ nullable: true })
  animalAge?: string;

  @Field(() => AnimalSex)
  animalSex: AnimalSex;

  @Field({ nullable: true })
  notes?: string;
}
