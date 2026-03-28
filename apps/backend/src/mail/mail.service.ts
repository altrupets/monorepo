import { Injectable, Logger } from '@nestjs/common';
import { MailerService } from '@nestjs-modules/mailer';

@Injectable()
export class MailService {
  private readonly logger = new Logger(MailService.name);

  constructor(private readonly mailerService: MailerService) {}

  async sendVerificationEmail(
    email: string,
    username: string,
    token: string,
    appUrl: string,
  ): Promise<void> {
    const verificationLink = `${appUrl}/auth/verify-email?token=${token}`;

    try {
      await this.mailerService.sendMail({
        to: email,
        subject: 'AltruPets - Verifica tu correo electronico',
        template: 'verification',
        context: {
          username,
          verificationLink,
          appUrl,
        },
      });
      this.logger.log(`Correo de verificacion enviado a ${email}`);
    } catch (error) {
      this.logger.error(
        `Error al enviar correo de verificacion a ${email}: ${error.message}`,
      );
      throw error;
    }
  }

  async sendPasswordResetEmail(
    email: string,
    username: string,
    token: string,
    appUrl: string,
  ): Promise<void> {
    const resetLink = `${appUrl}/auth/reset-password?token=${token}`;

    try {
      await this.mailerService.sendMail({
        to: email,
        subject: 'AltruPets - Restablecer contrasena',
        template: 'reset',
        context: {
          username,
          resetLink,
          appUrl,
        },
      });
      this.logger.log(`Correo de restablecimiento enviado a ${email}`);
    } catch (error) {
      this.logger.error(
        `Error al enviar correo de restablecimiento a ${email}: ${error.message}`,
      );
      throw error;
    }
  }
}
