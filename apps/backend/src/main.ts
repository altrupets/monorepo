import { NestFactory } from '@nestjs/core';
import { ValidationPipe } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import { NestExpressApplication } from '@nestjs/platform-express';
import { AppModule } from './app.module';
import { AuthService } from './auth/auth.service';
import cookieParser from 'cookie-parser';
import { inertiaMiddleware } from 'nestjs-inertia';
import { join } from 'path';

async function bootstrap() {
  const app = await NestFactory.create<NestExpressApplication>(AppModule);

  // Aumentar límite de tamaño para imágenes base64 (50MB)
  app.useBodyParser('json', { limit: '50mb' });

  // Cookie parser for JWT in cookies
  app.use(cookieParser());

  // Serve static files for Inertia.js frontend (built assets)
  const isProduction = process.env.NODE_ENV === 'production';
  if (isProduction) {
    app.useStaticAssets(join(__dirname, '..', 'public'));
  }

  // Inertia.js middleware
  app.use(inertiaMiddleware);

  const configService = app.get(ConfigService);
  const port = configService.get<number>('PORT', 3001);

  // Enable CORS for development
  app.enableCors({
    origin: [
      'http://localhost:5173', // Vite dev server
      'http://localhost:3000', // Alternative dev server
      'http://192.168.1.81:3001', // Laptop IP for mobile testing
      'http://192.168.1.81:5173',
    ],
    credentials: true,
  });

  app.useGlobalPipes(
    new ValidationPipe({
      whitelist: true,
      forbidNonWhitelisted: true,
      transform: true,
    }),
  );

  // Dev-only: seed an initial admin user for login (disabled by default for security)
  const seedEnabled =
    configService.get<string>('SEED_ADMIN', 'false') === 'true';
  if (seedEnabled) {
    const authService = app.get(AuthService);
    const username = configService.get<string>('SEED_ADMIN_USERNAME');
    const password = configService.get<string>('SEED_ADMIN_PASSWORD');

    if (!username || !password) {
      throw new Error(
        'SEED_ADMIN is enabled, but SEED_ADMIN_USERNAME/SEED_ADMIN_PASSWORD are missing',
      );
    }

    if (password.length < 12) {
      throw new Error(
        'SEED_ADMIN_PASSWORD must be at least 12 characters when SEED_ADMIN=true',
      );
    }

    await authService.createInitialAdmin(username, password);
  }

  await app.listen(port);
  const envName = configService.get<string>('ENV_NAME', 'dev').toUpperCase();
  console.log(
    `AltruPets ${envName} Backend is running on: http://localhost:${port}`,
  );
}
bootstrap().catch((err) => {
  console.error('Error starting server:', err);
  process.exit(1);
});
