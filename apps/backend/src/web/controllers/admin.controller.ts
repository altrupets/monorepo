import { Controller, Get, Res, UseGuards } from '@nestjs/common';
import type { Response } from 'express';
import { JwtAuthGuard } from '../../auth/jwt-auth.guard';
import { RolesGuard } from '../../auth/roles/roles.guard';
import { Roles } from '../../auth/roles/roles.decorator';
import { USER_ADMIN_ROLES } from '../../auth/roles/rbac-constants';

/**
 * Admin Controller - Panel de Administración
 * Solo accesible para usuarios con roles ADMIN
 */
@Controller('admin')
@UseGuards(JwtAuthGuard, RolesGuard)
export class AdminController {
  
  @Get()
  @Roles(...USER_ADMIN_ROLES)
  async index(@Res() res: Response) {
    // @ts-ignore - inertia is added by nestjs-inertia middleware
    return res.inertia.render('Admin/Dashboard', {
      title: 'Panel de Administración',
    });
  }

  @Get('users')
  @Roles(...USER_ADMIN_ROLES)
  async users(@Res() res: Response) {
    // @ts-ignore - inertia is added by nestjs-inertia middleware
    return res.inertia.render('Admin/Users/Index', {
      title: 'Gestión de Usuarios',
    });
  }

  @Get('users/:id')
  @Roles(...USER_ADMIN_ROLES)
  async userDetail(@Res() res: Response) {
    // @ts-ignore - inertia is added by nestjs-inertia middleware
    return res.inertia.render('Admin/Users/Detail', {
      title: 'Detalle de Usuario',
    });
  }
}
