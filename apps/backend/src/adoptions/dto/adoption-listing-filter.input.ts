import { InputType, Field } from '@nestjs/graphql';
import { IsOptional, IsBoolean, IsEnum } from 'class-validator';
import { AnimalSpecies } from '../../animals/entities/animal.entity';
import { AnimalSize } from '../enums/animal-size.enum';
import { AgeCategory } from '../enums/age-category.enum';

@InputType()
export class AdoptionListingFilterInput {
  @Field(() => AnimalSpecies, { nullable: true, description: 'Filtrar por especie' })
  @IsOptional()
  @IsEnum(AnimalSpecies)
  species?: AnimalSpecies;

  @Field(() => AnimalSize, { nullable: true, description: 'Filtrar por tamano' })
  @IsOptional()
  @IsEnum(AnimalSize)
  size?: AnimalSize;

  @Field(() => AgeCategory, { nullable: true, description: 'Filtrar por rango de edad' })
  @IsOptional()
  @IsEnum(AgeCategory)
  ageCategory?: AgeCategory;

  @Field({ nullable: true, description: 'Filtrar por amigable con ninos' })
  @IsOptional()
  @IsBoolean()
  isChildFriendly?: boolean;

  @Field({ nullable: true, description: 'Filtrar por amigable con mascotas' })
  @IsOptional()
  @IsBoolean()
  isPetFriendly?: boolean;

  @Field({ nullable: true, description: 'Filtrar por esterilizado' })
  @IsOptional()
  @IsBoolean()
  isSterilized?: boolean;
}
