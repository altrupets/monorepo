import { InputType, Field, ID } from '@nestjs/graphql';
import { IsUUID, IsString } from 'class-validator';

@InputType()
export class SubmitAdoptionApplicationInput {
  @Field(() => ID, { description: 'ID del listado de adopcion' })
  @IsUUID()
  listingId: string;

  @Field({ description: 'Descripcion del hogar del solicitante' })
  @IsString()
  homeDescription: string;

  @Field({ description: 'Descripcion de la familia del solicitante' })
  @IsString()
  familyDescription: string;

  @Field({ description: 'Experiencia previa con mascotas' })
  @IsString()
  petExperience: string;

  @Field({ description: 'Telefono de contacto' })
  @IsString()
  contactPhone: string;

  @Field({ description: 'Motivacion para adoptar' })
  @IsString()
  motivation: string;
}
