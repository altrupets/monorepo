import { Resolver, Query, Mutation, Args, ID, Int } from '@nestjs/graphql';
import { UseGuards } from '@nestjs/common';
import { NotificationsService } from './notifications.service.js';
import { Notification } from './entities/notification.entity.js';
import { DeviceToken } from './entities/device-token.entity.js';
import { NotificationPage } from './dto/notification.output.js';
import { RegisterDeviceTokenInput } from './dto/register-device-token.input.js';
import { JwtAuthGuard } from '../auth/jwt-auth.guard.js';
import { GqlUser } from '../auth/gql-user.decorator.js';
import { User } from '../users/entities/user.entity.js';

@Resolver(() => Notification)
export class NotificationsResolver {
  constructor(private readonly notificationsService: NotificationsService) {}

  @Mutation(() => DeviceToken)
  @UseGuards(JwtAuthGuard)
  async registerDeviceToken(
    @GqlUser() user: User,
    @Args('input') input: RegisterDeviceTokenInput,
  ): Promise<DeviceToken> {
    return this.notificationsService.registerToken(
      user.id,
      input.token,
      input.platform,
    );
  }

  @Mutation(() => Boolean)
  @UseGuards(JwtAuthGuard)
  async unregisterDeviceToken(
    @GqlUser() user: User,
    @Args('token') token: string,
  ): Promise<boolean> {
    return this.notificationsService.unregisterToken(user.id, token);
  }

  @Mutation(() => Notification)
  @UseGuards(JwtAuthGuard)
  async markNotificationRead(
    @GqlUser() user: User,
    @Args('id', { type: () => ID }) id: string,
  ): Promise<Notification> {
    return this.notificationsService.markAsRead(user.id, id);
  }

  @Mutation(() => Int)
  @UseGuards(JwtAuthGuard)
  async markAllNotificationsRead(
    @GqlUser() user: User,
  ): Promise<number> {
    return this.notificationsService.markAllAsRead(user.id);
  }

  @Query(() => NotificationPage, { name: 'myNotifications' })
  @UseGuards(JwtAuthGuard)
  async myNotifications(
    @GqlUser() user: User,
    @Args('page', { type: () => Int, nullable: true, defaultValue: 1 }) page: number,
    @Args('limit', { type: () => Int, nullable: true, defaultValue: 20 }) limit: number,
    @Args('unreadOnly', { nullable: true, defaultValue: false }) unreadOnly: boolean,
  ): Promise<NotificationPage> {
    return this.notificationsService.getUserNotifications(user.id, {
      page,
      limit,
      unreadOnly,
    });
  }
}
