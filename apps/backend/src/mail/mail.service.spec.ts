import { Test, TestingModule } from '@nestjs/testing';
import { MailService } from './mail.service';
import { MailerService } from '@nestjs-modules/mailer';

describe('MailService', () => {
  let service: MailService;
  let mockMailerService: any;

  beforeEach(async () => {
    mockMailerService = {
      sendMail: jest.fn().mockResolvedValue(undefined),
    };

    const module: TestingModule = await Test.createTestingModule({
      providers: [
        MailService,
        {
          provide: MailerService,
          useValue: mockMailerService,
        },
      ],
    }).compile();

    service = module.get<MailService>(MailService);
  });

  it('should be defined', () => {
    expect(service).toBeDefined();
  });

  describe('sendVerificationEmail', () => {
    it('should call mailerService.sendMail with correct parameters', async () => {
      await service.sendVerificationEmail(
        'user@example.com',
        'testuser',
        'abc123token',
        'http://localhost:3000',
      );

      expect(mockMailerService.sendMail).toHaveBeenCalledTimes(1);
      expect(mockMailerService.sendMail).toHaveBeenCalledWith({
        to: 'user@example.com',
        subject: 'AltruPets - Verifica tu correo electronico',
        template: 'verification',
        context: {
          username: 'testuser',
          verificationLink:
            'http://localhost:3000/auth/verify-email?token=abc123token',
          appUrl: 'http://localhost:3000',
        },
      });
    });

    it('should throw when mailerService fails', async () => {
      mockMailerService.sendMail.mockRejectedValue(
        new Error('SMTP connection failed'),
      );

      await expect(
        service.sendVerificationEmail(
          'user@example.com',
          'testuser',
          'token',
          'http://localhost:3000',
        ),
      ).rejects.toThrow('SMTP connection failed');
    });
  });

  describe('sendPasswordResetEmail', () => {
    it('should call mailerService.sendMail with correct parameters', async () => {
      await service.sendPasswordResetEmail(
        'user@example.com',
        'testuser',
        'reset123token',
        'http://localhost:3000',
      );

      expect(mockMailerService.sendMail).toHaveBeenCalledTimes(1);
      expect(mockMailerService.sendMail).toHaveBeenCalledWith({
        to: 'user@example.com',
        subject: 'AltruPets - Restablecer contrasena',
        template: 'reset',
        context: {
          username: 'testuser',
          resetLink:
            'http://localhost:3000/auth/reset-password?token=reset123token',
          appUrl: 'http://localhost:3000',
        },
      });
    });

    it('should throw when mailerService fails', async () => {
      mockMailerService.sendMail.mockRejectedValue(
        new Error('SMTP auth failed'),
      );

      await expect(
        service.sendPasswordResetEmail(
          'user@example.com',
          'testuser',
          'token',
          'http://localhost:3000',
        ),
      ).rejects.toThrow('SMTP auth failed');
    });
  });
});
