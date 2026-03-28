import { join } from 'path';
import { Module } from '@nestjs/common';
import { ConfigModule, ConfigService } from '@nestjs/config';
import { SentryModule } from '@sentry/nestjs/setup';
import { GraphQLModule } from '@nestjs/graphql';
import { ApolloDriver, ApolloDriverConfig } from '@nestjs/apollo';
import { TypeOrmModule } from '@nestjs/typeorm';
import { CacheModule } from '@nestjs/cache-manager';
import { redisStore } from 'cache-manager-redis-yet';
import { ThrottlerModule } from '@nestjs/throttler';
import { ScheduleModule } from '@nestjs/schedule';
import { AppController } from './app.controller';
import { AppService } from './app.service';
import { AuthModule } from './auth/auth.module';
import { HealthModule } from './health/health.module';
import { UsersModule } from './users/users.module';
import { User } from './users/entities/user.entity';
import { CapturesModule } from './captures/captures.module';
import { CaptureRequest } from './captures/entities/capture-request.entity';
import { WebModule } from './web/web.module';
import { OrganizationsModule } from './organizations/organizations.module';
import { Organization } from './organizations/entities/organization.entity';
import { OrganizationMembership } from './organizations/entities/organization-membership.entity';
import { VetProfilesModule } from './vet-profiles/vet-profiles.module';
import { VetProfile } from './vet-profiles/entities/vet-profile.entity';
import { JurisdictionsModule } from './jurisdictions/jurisdictions.module';
import { Jurisdiction } from './jurisdictions/entities/jurisdiction.entity';
import { AbuseReportsModule } from './abuse-reports/abuse-reports.module';
import { AbuseReport } from './abuse-reports/entities/abuse-report.entity';
import { SubsidiesModule } from './subsidies/subsidies.module';
import { SubsidyRequest } from './subsidies/entities/subsidy-request.entity';
import { NotificationsModule } from './notifications/notifications.module';
import { DeviceToken } from './notifications/entities/device-token.entity';
import { Notification } from './notifications/entities/notification.entity';
import { MailModule } from './mail/mail.module';

@Module({
  imports: [
    SentryModule.forRoot(),
    ConfigModule.forRoot({
      isGlobal: true,
    }),
    ScheduleModule.forRoot(),
    ThrottlerModule.forRootAsync({
      imports: [ConfigModule],
      useFactory: (configService: ConfigService) => ({
        throttlers: [
          {
            name: 'default',
            ttl: configService.get<number>('THROTTLE_TTL', 60000),
            limit: configService.get<number>('THROTTLE_LIMIT', 100),
          },
          {
            name: 'short',
            ttl: configService.get<number>('THROTTLE_SHORT_TTL', 1000),
            limit: configService.get<number>('THROTTLE_SHORT_LIMIT', 10),
          },
        ],
      }),
      inject: [ConfigService],
    }),
    TypeOrmModule.forRootAsync({
      imports: [ConfigModule],
      useFactory: (configService: ConfigService) => ({
        type: 'postgres',
        host: configService.get<string>('DB_HOST', 'localhost'),
        port: configService.get<number>('DB_PORT', 5432),
        username: configService.get<string>('DB_USERNAME', 'postgres'),
        password: configService.get<string>('DB_PASSWORD', 'postgres'),
        database: (() => {
          const dbName = configService.get<string>('DB_NAME');
          if (dbName && dbName.trim().length > 0) {
            return dbName;
          }
          const envName = configService.get<string>('ENV_NAME', 'dev');
          return `altrupets_${envName}_database`;
        })(),
        entities: [
          User,
          CaptureRequest,
          Organization,
          OrganizationMembership,
          VetProfile,
          Jurisdiction,
          AbuseReport,
          SubsidyRequest,
          DeviceToken,
          Notification,
        ],
        synchronize: configService.get<string>('NODE_ENV') !== 'production',
        migrations: [join(__dirname, 'migrations', '*{.ts,.js}')],
        migrationsRun: false,
      }),
      inject: [ConfigService],
    }),
    CacheModule.registerAsync({
      isGlobal: true,
      imports: [ConfigModule],
      useFactory: async (configService: ConfigService) => {
        const redisHost = configService.get<string>('REDIS_HOST');
        const redisUrl = configService.get<string>('REDIS_URL');

        if (redisHost || redisUrl) {
          const storeConfig = redisUrl
            ? { url: redisUrl }
            : {
                socket: {
                  host: redisHost,
                  port: configService.get<number>('REDIS_PORT', 6379),
                },
              };

          const store = await redisStore({
            ...storeConfig,
            ttl: configService.get<number>('CACHE_TTL', 600) * 1000,
          });

          return { store: () => store };
        }

        // Fall back to in-memory cache (no Redis configured)
        return {
          ttl: configService.get<number>('CACHE_TTL', 600) * 1000,
        };
      },
      inject: [ConfigService],
    }),
    GraphQLModule.forRoot<ApolloDriverConfig>({
      driver: ApolloDriver,
      autoSchemaFile: join(process.cwd(), 'schema.gql'),
      sortSchema: true,
      csrfPrevention: false,
    }),
    AuthModule,
    HealthModule,
    UsersModule,
    CapturesModule,
    WebModule,
    OrganizationsModule,
    VetProfilesModule,
    JurisdictionsModule,
    AbuseReportsModule,
    SubsidiesModule,
    NotificationsModule,
    MailModule,
  ],
  controllers: [AppController],
  providers: [AppService],
})
export class AppModule {}
