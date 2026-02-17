import { Controller, Get, Res, UseGuards } from '@nestjs/common';
import type { Response } from 'express';
import { JwtAuthGuard } from '../../auth/jwt-auth.guard';
import { RolesGuard } from '../../auth/roles/roles.guard';
import { Roles } from '../../auth/roles/roles.decorator';
import { CAPTURE_VIEWER_ROLES } from '../../auth/roles/rbac-constants';

/**
 * B2G Controller - Panel para Gobiernos Locales
 * Solo accesible para usuarios B2G
 */
@Controller('b2g')
@UseGuards(JwtAuthGuard, RolesGuard)
export class B2gController {
  
  @Get()
  @Roles(...CAPTURE_VIEWER_ROLES)
  async index(@Res() res: Response) {
    // @ts-ignore - inertia is added by nestjs-inertia middleware
    return res.inertia.render('B2G/Dashboard', {
      title: 'Panel B2G - Gobierno Local',
    });
  }

  @Get('captures')
  @Roles(...CAPTURE_VIEWER_ROLES)
  async captures(@Res() res: Response) {
    // @ts-ignore - inertia is added by nestjs-inertia middleware
    return res.inertia.render('B2G/Captures/Index', {
      title: 'Solicitudes de Captura',
    });
  }

  @Get('captures/:id')
  @Roles(...CAPTURE_VIEWER_ROLES)
  async captureDetail(@Res() res: Response) {
    // @ts-ignore - inertia is added by nestjs-inertia middleware
    return res.inertia.render('B2G/Captures/Detail', {
      title: 'Detalle de Solicitud',
    });
  }
}
