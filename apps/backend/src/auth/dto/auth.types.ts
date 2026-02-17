import { Field, ObjectType, InputType } from '@nestjs/graphql';
import { UserRole } from '../roles/user-role.enum';

@ObjectType()
export class AuthPayload {
  @Field()
  access_token: string;

  @Field()
  refresh_token: string;

  @Field()
  expires_in: number;
}

@ObjectType()
export class UserProfile {
  @Field()
  userId: string;

  @Field()
  username: string;

  @Field(() => [UserRole])
  roles: UserRole[];
}

@InputType()
export class RefreshTokenInput {
  @Field()
  refresh_token: string;
}
