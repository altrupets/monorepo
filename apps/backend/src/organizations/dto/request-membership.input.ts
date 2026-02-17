import { InputType, Field, ID } from '@nestjs/graphql';
import { IsString, IsUUID, IsOptional } from 'class-validator';

@InputType()
export class RequestMembershipInput {
  @Field(() => ID)
  @IsUUID()
  organizationId: string;

  @Field({ nullable: true })
  @IsString()
  @IsOptional()
  requestMessage?: string;
}
