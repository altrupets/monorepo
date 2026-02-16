import { Field, ObjectType } from '@nestjs/graphql';
import { UserRole } from '../roles/user-role.enum';

@ObjectType()
export class AuthPayload {
  @Field()
  access_token: string;
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
