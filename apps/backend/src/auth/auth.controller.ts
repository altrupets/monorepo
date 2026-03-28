import { Controller, Get, Query, Res, Logger } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import type { Response } from 'express';
import { AuthService } from './auth.service';

@Controller('auth')
export class AuthController {
  private readonly logger = new Logger(AuthController.name);

  constructor(
    private readonly authService: AuthService,
    private readonly configService: ConfigService,
  ) {}

  @Get('verify-email')
  async verifyEmail(
    @Query('token') token: string,
    @Res() res: Response,
  ) {
    const appUrl = this.configService.get<string>(
      'APP_URL',
      'http://localhost:3000',
    );

    try {
      await this.authService.verifyEmailToken(token);
      res.redirect(`${appUrl}/verified`);
    } catch (error) {
      this.logger.error(
        `[verifyEmail] Error al verificar email: ${error.message}`,
      );
      res.redirect(`${appUrl}/verified?error=invalid_token`);
    }
  }
}
