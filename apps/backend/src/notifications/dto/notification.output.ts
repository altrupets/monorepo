import { ObjectType, Field, Int } from '@nestjs/graphql';
import { Notification } from '../entities/notification.entity.js';

@ObjectType()
export class NotificationPage {
  @Field(() => [Notification])
  notifications: Notification[];

  @Field(() => Int)
  total: number;

  @Field(() => Int)
  unreadCount: number;
}
