import { InputType, Field, ID } from '@nestjs/graphql';
import { IsUUID, IsString, IsOptional, IsBoolean, IsArray } from 'class-validator';

@InputType()
export class CreateAdoptionListingInput {
  @Field(() => ID, { description: 'ID del animal a publicar' })
  @IsUUID()
  animalId: string;

  @Field({ description: 'Titulo del listado de adopcion' })
  @IsString()
  title: string;

  @Field({ description: 'Descripcion del animal y su historia' })
  @IsString()
  description: string;

  @Field({ nullable: true, description: 'Requisitos para adoptar' })
  @IsOptional()
  @IsString()
  requirements?: string;

  @Field(() => [String], { nullable: true, description: 'Temperamento del animal' })
  @IsOptional()
  @IsArray()
  @IsString({ each: true })
  temperament?: string[];

  @Field({ nullable: true, defaultValue: false, description: 'Amigable con ninos' })
  @IsOptional()
  @IsBoolean()
  isChildFriendly?: boolean;

  @Field({ nullable: true, defaultValue: false, description: 'Amigable con otras mascotas' })
  @IsOptional()
  @IsBoolean()
  isPetFriendly?: boolean;

  @Field({ nullable: true, description: 'Descripcion de la ubicacion' })
  @IsOptional()
  @IsString()
  locationDescription?: string;
}
