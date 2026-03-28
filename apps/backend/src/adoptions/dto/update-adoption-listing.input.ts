import { InputType, Field } from '@nestjs/graphql';
import { IsString, IsOptional, IsBoolean, IsArray } from 'class-validator';

@InputType()
export class UpdateAdoptionListingInput {
  @Field({ nullable: true, description: 'Titulo del listado de adopcion' })
  @IsOptional()
  @IsString()
  title?: string;

  @Field({ nullable: true, description: 'Descripcion del animal y su historia' })
  @IsOptional()
  @IsString()
  description?: string;

  @Field({ nullable: true, description: 'Requisitos para adoptar' })
  @IsOptional()
  @IsString()
  requirements?: string;

  @Field(() => [String], { nullable: true, description: 'Temperamento del animal' })
  @IsOptional()
  @IsArray()
  @IsString({ each: true })
  temperament?: string[];

  @Field({ nullable: true, description: 'Amigable con ninos' })
  @IsOptional()
  @IsBoolean()
  isChildFriendly?: boolean;

  @Field({ nullable: true, description: 'Amigable con otras mascotas' })
  @IsOptional()
  @IsBoolean()
  isPetFriendly?: boolean;

  @Field({ nullable: true, description: 'Descripcion de la ubicacion' })
  @IsOptional()
  @IsString()
  locationDescription?: string;
}
