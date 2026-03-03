# PASO 3: Crear /apps/agent (NestJS + GraphQL)

## 3.1 Scaffold

```bash
cd apps
mkdir -p agent/src/{agent,graph,memory,observability,health,config}
cd agent
```

## 3.2 package.json

```json
{
  "name": "@altrupets/agent",
  "version": "1.0.0",
  "private": true,
  "scripts": {
    "build": "nest build",
    "start": "nest start",
    "start:dev": "nest start --watch",
    "start:debug": "nest start --debug --watch",
    "start:prod": "node dist/main",
    "lint": "eslint \"{src,test}/**/*.ts\" --fix",
    "test": "jest",
    "test:e2e": "jest --config ./test/jest-e2e.json"
  },
  "dependencies": {
    "@nestjs/common": "^11.0.1",
    "@nestjs/core": "^11.0.1",
    "@nestjs/config": "^4.0.0",
    "@nestjs/graphql": "^13.2.3",
    "@nestjs/platform-express": "^11.0.1",
    "@nestjs/jwt": "^11.0.2",
    "@nestjs/passport": "^11.0.5",
    "@nestjs/terminus": "^11.0.0",
    "@apollo/server": "^5.2.0",
    "graphql": "^16.12.0",
    "passport": "^0.7.0",
    "passport-jwt": "^4.0.1",
    "express": "^5.2.1",
    "reflect-metadata": "^0.2.2",
    "rxjs": "^7.8.1",
    "@langchain/core": "^0.3.40",
    "@langchain/langgraph": "^0.2.60",
    "@langchain/openai": "^0.4.10",
    "@getzep/zep-cloud": "^2.8.0",
    "langfuse": "^3.35.0",
    "ioredis": "^5.6.0"
  },
  "devDependencies": {
    "@nestjs/cli": "^11.0.0",
    "@nestjs/schematics": "^11.0.0",
    "@nestjs/testing": "^11.0.1",
    "@types/express": "^5.0.0",
    "@types/jest": "^29.5.14",
    "@types/node": "^22.12.0",
    "@types/passport-jwt": "^4.0.1",
    "jest": "^29.7.0",
    "ts-jest": "^29.2.5",
    "ts-loader": "^9.5.1",
    "ts-node": "^10.9.2",
    "typescript": "^5.7.3"
  }
}
```

## 3.3 tsconfig.json

```json
{
  "compilerOptions": {
    "module": "commonjs",
    "declaration": true,
    "removeComments": true,
    "emitDecoratorMetadata": true,
    "experimentalDecorators": true,
    "allowSyntheticDefaultImports": true,
    "target": "ES2023",
    "sourceMap": true,
    "outDir": "./dist",
    "baseUrl": "./",
    "incremental": true,
    "skipLibCheck": true,
    "strictNullChecks": true,
    "noImplicitAny": true,
    "strictBindCallApply": true,
    "forceConsistentCasingInFileNames": true,
    "noFallthroughCasesInSwitch": true,
    "paths": {
      "@/*": ["src/*"]
    }
  },
  "include": ["src/**/*"],
  "exclude": ["node_modules", "dist"]
}
```

## 3.4 nest-cli.json

```json
{
  "$schema": "https://json.schemastore.org/nest-cli",
  "collection": "@nestjs/schematics",
  "sourceRoot": "src",
  "compilerOptions": {
    "deleteOutDir": true
  }
}
```

## 3.5 src/main.ts

```ts
import { NestFactory } from '@nestjs/core';
import { AppModule } from './app.module';
import { ConfigService } from '@nestjs/config';

async function bootstrap() {
  const app = await NestFactory.create(AppModule);
  const config = app.get(ConfigService);

  // CORS — permite peticiones desde mobile y backend
  app.enableCors({
    origin: [
      'http://localhost:3001',       // backend
      'http://localhost:5173',       // web dev
      'http://192.168.1.81:*',      // dispositivo físico local
    ],
    credentials: true,
  });

  const port = config.get<number>('PORT', 3002);
  await app.listen(port);
  console.log(`Agent GraphQL running on http://localhost:${port}/graphql`);
}
bootstrap();
```

## 3.6 src/app.module.ts

```ts
import { Module } from '@nestjs/common';
import { ConfigModule } from '@nestjs/config';
import { GraphQLModule } from '@nestjs/graphql';
import { ApolloDriver, ApolloDriverConfig } from '@nestjs/graphql';
import { AgentModule } from './agent/agent.module';
import { HealthModule } from './health/health.module';
import { MemoryModule } from './memory/memory.module';
import { ObservabilityModule } from './observability/observability.module';

@Module({
  imports: [
    ConfigModule.forRoot({
      isGlobal: true,
      envFilePath: ['.env.local', '.env'],
    }),
    GraphQLModule.forRoot<ApolloDriverConfig>({
      driver: ApolloDriver,
      autoSchemaFile: 'schema.gql',
      sortSchema: true,
      playground: process.env.NODE_ENV !== 'production',
      context: ({ req }) => ({ req }),
    }),
    AgentModule,
    MemoryModule,
    ObservabilityModule,
    HealthModule,
  ],
})
export class AppModule {}
```

## 3.7 Health Module

```ts
// src/health/health.module.ts
import { Module } from '@nestjs/common';
import { TerminusModule } from '@nestjs/terminus';
import { HealthController } from './health.controller';

@Module({
  imports: [TerminusModule],
  controllers: [HealthController],
})
export class HealthModule {}
```

```ts
// src/health/health.controller.ts
import { Controller, Get } from '@nestjs/common';
import { HealthCheck, HealthCheckService } from '@nestjs/terminus';

@Controller('health')
export class HealthController {
  constructor(private health: HealthCheckService) {}

  @Get()
  @HealthCheck()
  check() {
    return this.health.check([]);
  }
}
```

## 3.8 src/config/env.ts

```ts
export const envConfig = () => ({
  port: parseInt(process.env.PORT, 10) || 3002,
  nodeEnv: process.env.NODE_ENV || 'development',

  falkordb: {
    host: process.env.FALKORDB_HOST || 'falkordb-service.altrupets-dev.svc.cluster.local',
    port: parseInt(process.env.FALKORDB_PORT, 10) || 6379,
    password: process.env.FALKORDB_PASSWORD || '',
  },

  zep: {
    apiKey: process.env.ZEP_API_KEY || '',
    apiUrl: process.env.ZEP_API_URL || '',
  },

  langfuse: {
    publicKey: process.env.LANGFUSE_PUBLIC_KEY || '',
    secretKey: process.env.LANGFUSE_SECRET_KEY || '',
    baseUrl: process.env.LANGFUSE_BASE_URL || 'https://cloud.langfuse.com',
  },

  llm: {
    openaiApiKey: process.env.OPENAI_API_KEY || '',
    model: process.env.LLM_MODEL || 'gpt-4o',
  },

  jwt: {
    secret: process.env.JWT_SECRET || 'super-secret-altrupets-key-2026',
  },

  backend: {
    graphqlUrl: process.env.BACKEND_GRAPHQL_URL ||
      'http://backend-service.altrupets-dev.svc.cluster.local:3001/graphql',
  },
});
```
