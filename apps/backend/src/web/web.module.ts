import { Module } from '@nestjs/common';
import { AdminController } from './controllers/admin.controller';
import { B2gController } from './controllers/b2g.controller';
import { WebAuthController } from './controllers/web-auth.controller';
import { AuthModule } from '../auth/auth.module';

/**
 * Web Module - Inertia.js Routes for Web Application
 * Provides routes for Admin and B2G panels using Inertia.js
 */
@Module({
  imports: [AuthModule],
  controllers: [AdminController, B2gController, WebAuthController],
})
export class WebModule {}
