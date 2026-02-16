import { join } from 'path';
import { Module } from '@nestjs/common';
import { ConfigModule, ConfigService } from '@nestjs/config';
import { GraphQLModule } from '@nestjs/graphql';
import { ApolloDriver, ApolloDriverConfig } from '@nestjs/apollo';
import { TypeOrmModule } from '@nestjs/typeorm';
import { CacheModule } from '@nestjs/cache-manager';
import { AppController } from './app.controller';
import { AppService } from './app.service';
import { AuthModule } from './auth/auth.module';
import { HealthModule } from './health/health.module';
import { UsersModule } from './users/users.module';
import { User } from './users/entities/user.entity';
import { CapturesModule } from './captures/captures.module';
import { CaptureRequest } from './captures/entities/capture-request.entity';

@Module({
  imports: [
    ConfigModule.forRoot({
      isGlobal: true,
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
        entities: [User, CaptureRequest],
        synchronize: true, // Only for development
      }),
      inject: [ConfigService],
    }),
    CacheModule.registerAsync({
      isGlobal: true,
      imports: [ConfigModule],
      useFactory: async (configService: ConfigService) => {
        const ttlMs = configService.get<number>('CACHE_TTL', 600) * 1000; // 10 minutes default
        const redisUrl = configService.get<string>('REDIS_URL');
        if (redisUrl) {
          console.warn(
            'REDIS_URL is set but Redis cache adapter is not configured; using in-memory cache for now.',
          );
        }

        return {
          ttl: ttlMs,
        };
      },
      inject: [ConfigService],
    }),
    GraphQLModule.forRoot<ApolloDriverConfig>({
      driver: ApolloDriver,
      autoSchemaFile: join(process.cwd(), 'schema.gql'),
      sortSchema: true,
    }),
    AuthModule,
    HealthModule,
    UsersModule,
    CapturesModule,
  ],
  controllers: [AppController],
  providers: [AppService],
})
export class AppModule { }
