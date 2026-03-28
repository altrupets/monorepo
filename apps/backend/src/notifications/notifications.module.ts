import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { DeviceToken } from './entities/device-token.entity.js';
import { Notification } from './entities/notification.entity.js';
import { NotificationsService } from './notifications.service.js';
import { NotificationsResolver } from './notifications.resolver.js';

// NOTE: New entities (DeviceToken, Notification) require TypeORM migrations.
// Migrations will be generated and applied separately during deploy.
@Module({
  imports: [TypeOrmModule.forFeature([DeviceToken, Notification])],
  providers: [NotificationsService, NotificationsResolver],
  exports: [NotificationsService],
})
export class NotificationsModule {}
