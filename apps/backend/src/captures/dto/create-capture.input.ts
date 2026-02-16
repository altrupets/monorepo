import { InputType, Field, Float } from '@nestjs/graphql';
import { IsNotEmpty, IsOptional, MaxLength } from 'class-validator';

@InputType()
export class CreateCaptureInput {
    @Field(() => Float)
    latitude: number;

    @Field(() => Float)
    longitude: number;

    @Field({ nullable: true })
    @IsOptional()
    @MaxLength(500)
    description?: string;

    @Field()
    @IsNotEmpty()
    animalType: string;

    @Field({ description: 'Base64 encoded image string for local dev' })
    @IsNotEmpty()
    imageBase64: string;
}
