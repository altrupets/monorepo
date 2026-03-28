import {
  Injectable,
  Logger,
  NotFoundException,
  ForbiddenException,
  OnModuleInit,
} from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository, EntityManager, MoreThan, In } from 'typeorm';
import { Cron } from '@nestjs/schedule';
import * as admin from 'firebase-admin';
import { DeviceToken } from './entities/device-token.entity.js';
import { Notification } from './entities/notification.entity.js';
import { NotificationType } from './enums/notification-type.enum.js';
import { DevicePlatform } from './enums/device-platform.enum.js';
import { User } from '../users/entities/user.entity.js';
import { UserRole } from '../auth/roles/user-role.enum.js';

interface SendNotificationParams {
  userId: string;
  type: NotificationType;
  title: string;
  body: string;
  data?: Record<string, unknown>;
  referenceId?: string;
  referenceType?: string;
}

interface SendToRoleParams {
  role: UserRole;
  type: NotificationType;
  title: string;
  body: string;
  data?: Record<string, unknown>;
  referenceId?: string;
  referenceType?: string;
  jurisdictionId?: string;
}

@Injectable()
export class NotificationsService implements OnModuleInit {
  private readonly logger = new Logger(NotificationsService.name);
  private firebaseInitialized = false;

  constructor(
    @InjectRepository(DeviceToken)
    private readonly deviceTokenRepository: Repository<DeviceToken>,
    @InjectRepository(Notification)
    private readonly notificationRepository: Repository<Notification>,
    private readonly entityManager: EntityManager,
  ) {}

  onModuleInit() {
    this.initFirebase();
  }

  private initFirebase(): void {
    try {
      const serviceAccountJson = process.env.FIREBASE_SERVICE_ACCOUNT_JSON;
      if (!serviceAccountJson) {
        this.logger.warn(
          'FIREBASE_SERVICE_ACCOUNT_JSON not set -- push notifications disabled',
        );
        return;
      }

      const serviceAccount = JSON.parse(serviceAccountJson);
      admin.initializeApp({
        credential: admin.credential.cert(serviceAccount),
      });

      this.firebaseInitialized = true;
      this.logger.log('Firebase Admin SDK initialized successfully');
    } catch (error) {
      this.logger.error(
        'Failed to initialize Firebase Admin SDK -- push notifications disabled',
        error instanceof Error ? error.message : String(error),
      );
    }
  }

  // -- Device token management --

  async registerToken(
    userId: string,
    token: string,
    platform: DevicePlatform,
  ): Promise<DeviceToken> {
    const existing = await this.deviceTokenRepository.findOne({
      where: { userId, token },
    });

    if (existing) {
      existing.isActive = true;
      existing.platform = platform;
      return this.deviceTokenRepository.save(existing);
    }

    const deviceToken = this.deviceTokenRepository.create({
      userId,
      token,
      platform,
      isActive: true,
    });

    return this.deviceTokenRepository.save(deviceToken);
  }

  async unregisterToken(userId: string, token: string): Promise<boolean> {
    const deviceToken = await this.deviceTokenRepository.findOne({
      where: { userId, token },
    });

    if (!deviceToken) {
      return false;
    }

    deviceToken.isActive = false;
    await this.deviceTokenRepository.save(deviceToken);
    return true;
  }

  // -- Notification sending --

  async sendToUser(params: SendNotificationParams): Promise<Notification> {
    const { userId, type, title, body, data, referenceId, referenceType } =
      params;

    // Deduplicate: check for identical notification within 60 seconds
    if (referenceId) {
      const recentDuplicate = await this.notificationRepository.findOne({
        where: {
          userId,
          type,
          referenceId,
          createdAt: MoreThan(new Date(Date.now() - 60_000)),
        },
      });

      if (recentDuplicate) {
        this.logger.debug(
          `Skipping duplicate notification: type=${type}, referenceId=${referenceId}, userId=${userId}`,
        );
        return recentDuplicate;
      }
    }

    // Persist the notification
    const notification = this.notificationRepository.create({
      userId,
      type,
      title,
      body,
      data,
      referenceId,
      referenceType,
    });

    const saved = await this.notificationRepository.save(notification);

    // Send push notification asynchronously (do not block)
    this.sendPushToUser(userId, saved).catch((error) => {
      this.logger.error(
        `Failed to send push to user ${userId}`,
        error instanceof Error ? error.message : String(error),
      );
    });

    return saved;
  }

  async sendToUsers(params: {
    userIds: string[];
    type: NotificationType;
    title: string;
    body: string;
    data?: Record<string, unknown>;
    referenceId?: string;
    referenceType?: string;
  }): Promise<Notification[]> {
    const { userIds, ...rest } = params;
    const promises = userIds.map((userId) =>
      this.sendToUser({ userId, ...rest }),
    );
    return Promise.all(promises);
  }

  async sendToRole(params: SendToRoleParams): Promise<Notification[]> {
    const { role, jurisdictionId, ...notificationData } = params;

    // Find users who have the specified role
    const queryBuilder = this.entityManager
      .createQueryBuilder(User, 'user')
      .where(':role = ANY(user.roles)', { role })
      .andWhere('user.isActive = :isActive', { isActive: true });

    if (jurisdictionId) {
      queryBuilder.andWhere('user.organizationId = :jurisdictionId', {
        jurisdictionId,
      });
    }

    const users = await queryBuilder.getMany();

    if (users.length === 0) {
      return [];
    }

    return this.sendToUsers({
      userIds: users.map((u) => u.id),
      ...notificationData,
    });
  }

  // -- Push delivery via FCM --

  private async sendPushToUser(
    userId: string,
    notification: Notification,
  ): Promise<void> {
    if (!this.firebaseInitialized) {
      return;
    }

    const activeTokens = await this.deviceTokenRepository.find({
      where: { userId, isActive: true },
    });

    if (activeTokens.length === 0) {
      return;
    }

    const tokens = activeTokens.map((dt) => dt.token);

    try {
      const message: admin.messaging.MulticastMessage = {
        tokens,
        notification: {
          title: notification.title,
          body: notification.body,
        },
        data: {
          notificationId: notification.id,
          type: notification.type,
          ...(notification.referenceId
            ? { referenceId: notification.referenceId }
            : {}),
          ...(notification.referenceType
            ? { referenceType: notification.referenceType }
            : {}),
          ...(notification.data
            ? Object.fromEntries(
                Object.entries(notification.data).map(([k, v]) => [k, String(v)]),
              )
            : {}),
        },
      };

      const response = await admin.messaging().sendEachForMulticast(message);

      // Mark invalid tokens as inactive
      for (let i = 0; i < response.responses.length; i++) {
        const sendResponse = response.responses[i];
        if (
          sendResponse !== undefined &&
          !sendResponse.success &&
          sendResponse.error
        ) {
          const errorCode = sendResponse.error.code;
          if (
            errorCode === 'messaging/invalid-registration-token' ||
            errorCode === 'messaging/registration-token-not-registered'
          ) {
            await this.deviceTokenRepository.update(
              { token: tokens[i] },
              { isActive: false },
            );
          }
        }
      }

      // Update notification with push status
      notification.pushSent = response.successCount > 0;
      notification.pushSentAt = new Date();
      if (response.failureCount > 0 && response.successCount === 0) {
        notification.pushError = `All ${response.failureCount} push attempts failed`;
      }
      await this.notificationRepository.save(notification);
    } catch (error) {
      notification.pushError =
        error instanceof Error ? error.message : String(error);
      await this.notificationRepository.save(notification);
    }
  }

  // -- Read state management --

  async markAsRead(userId: string, notificationId: string): Promise<Notification> {
    const notification = await this.notificationRepository.findOne({
      where: { id: notificationId },
    });

    if (!notification) {
      throw new NotFoundException(
        `Notification with ID ${notificationId} not found`,
      );
    }

    if (notification.userId !== userId) {
      throw new ForbiddenException('You can only mark your own notifications as read');
    }

    notification.isRead = true;
    return this.notificationRepository.save(notification);
  }

  async markAllAsRead(userId: string): Promise<number> {
    const result = await this.notificationRepository.update(
      { userId, isRead: false },
      { isRead: true },
    );
    return result.affected ?? 0;
  }

  // -- Query --

  async getUserNotifications(
    userId: string,
    options: { page?: number; limit?: number; unreadOnly?: boolean },
  ): Promise<{ notifications: Notification[]; total: number; unreadCount: number }> {
    const page = options.page ?? 1;
    const limit = options.limit ?? 20;
    const skip = (page - 1) * limit;

    const whereCondition: Record<string, unknown> = { userId };
    if (options.unreadOnly) {
      whereCondition.isRead = false;
    }

    const [notifications, total] = await this.notificationRepository.findAndCount({
      where: whereCondition,
      order: { createdAt: 'DESC' },
      skip,
      take: limit,
    });

    const unreadCount = await this.notificationRepository.count({
      where: { userId, isRead: false },
    });

    return { notifications, total, unreadCount };
  }

  // -- Scheduled cleanup --

  @Cron('0 3 * * *')
  async cleanInvalidTokens(): Promise<void> {
    const thirtyDaysAgo = new Date(Date.now() - 30 * 24 * 60 * 60 * 1000);

    const result = await this.deviceTokenRepository
      .createQueryBuilder()
      .delete()
      .where('isActive = :isActive', { isActive: false })
      .andWhere('updatedAt < :date', { date: thirtyDaysAgo })
      .execute();

    this.logger.log(
      `Cleaned up ${result.affected ?? 0} inactive device tokens older than 30 days`,
    );
  }
}
