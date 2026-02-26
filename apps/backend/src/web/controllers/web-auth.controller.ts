import { Controller, Get, Post, Res, Body, UnauthorizedException } from '@nestjs/common';
import type { Response } from 'express';
import { AuthService } from '../../auth/auth.service';
import { USER_ADMIN_ROLES, CAPTURE_VIEWER_ROLES } from '../../auth/roles/rbac-constants';

/**
 * Auth Controller - Web Authentication
 * Handles login/logout for Inertia.js web application
 */
@Controller()
export class WebAuthController {
  constructor(private readonly authService: AuthService) {}

  @Get('login')
  async loginPage(@Res() res: Response) {
    // @ts-ignore - inertia is added by @lapc506/nestjs-inertia middleware
    return res.inertia.render('Auth/Login', {
      title: 'Iniciar Sesión',
    });
  }

  @Post('login')
  async login(
    @Body() loginInput: { username: string; password: string },
    @Res() res: Response,
  ) {
    try {
      const user = await this.authService.validateUser(
        loginInput.username,
        loginInput.password,
      );

      const result = await this.authService.login(user);

      res.cookie('jwt', result.access_token, {
        httpOnly: true,
        secure: process.env.NODE_ENV === 'production',
        sameSite: 'strict',
        maxAge: 24 * 60 * 60 * 1000,
      });

      const userWithRoles = await this.authService.validateToken(result.access_token);
      const hasUserAdminRole = userWithRoles.roles.some(role => USER_ADMIN_ROLES.includes(role as any));
      const hasCaptureViewerRole = userWithRoles.roles.some(role => CAPTURE_VIEWER_ROLES.includes(role as any));

      if (hasUserAdminRole) {
        return res.redirect('/admin');
      } else if (hasCaptureViewerRole) {
        return res.redirect('/b2g');
      }

      return res.redirect('/');
    } catch (error) {
      // Extraer mensaje de error específico o usar genérico
      const errorMessage = error.message || 'Credenciales inválidas';
      let userMessage = 'Credenciales inválidas. Por favor intenta de nuevo.';

      if (errorMessage.includes('USER_NOT_FOUND')) {
        userMessage = 'El usuario no existe o fue eliminado de nuestra base de datos.';
      } else if (errorMessage.includes('INVALID_PASSWORD')) {
        userMessage = 'La contraseña es incorrecta. Por favor intenta de nuevo.';
      } else if (errorMessage.includes('ACCOUNT_LOCKED')) {
        userMessage = 'Tu cuenta está temporalmente bloqueada. Intenta de nuevo más tarde.';
      }

      // @ts-ignore - inertia is added by @lapc506/nestjs-inertia middleware
      return res.inertia.render('Auth/Login', {
        title: 'Iniciar Sesión',
        errors: { login: userMessage },
      });
    }
  }

  @Post('logout')
  async logout(@Res() res: Response) {
    res.clearCookie('jwt');
    return res.redirect('/login');
  }
}
