# Tareas: Verificacion de Correo y Restablecimiento de Contrasena

**Change ID**: `auth-email-password`
**Sprint**: 3 | **Tamano**: S (horas)
**Dependencia**: T0-3 (Done)

---

## Fase 1: MailModule

- [ ] Instalar dependencias: `@nestjs-modules/mailer`, `handlebars`
- [ ] Crear `src/mail/mail.module.ts` con configuracion SMTP via `ConfigService`
- [ ] Crear `src/mail/mail.service.ts` con metodos `sendVerificationEmail()` y `sendPasswordResetEmail()`
- [ ] Crear plantilla Handlebars `src/mail/templates/verification.hbs` (espanol, con logo, enlace, expiracion)
- [ ] Crear plantilla Handlebars `src/mail/templates/reset.hbs` (espanol, con logo, enlace, advertencia)
- [ ] Importar `MailModule` en `AppModule`
- [ ] Agregar variables de entorno SMTP al `.env.example`: `SMTP_HOST`, `SMTP_PORT`, `SMTP_SECURE`, `SMTP_USER`, `SMTP_PASS`, `MAIL_FROM`, `APP_URL`

## Fase 2: Verificacion de Correo

- [ ] Agregar metodo `sendVerificationEmail(userId)` a `AuthService` — genera token con `randomBytes(32)`, almacena en Redis como `verify:<token>`, envia email
- [ ] Agregar metodo `verifyEmailToken(token)` a `AuthService` — valida token en Redis, actualiza `isVerified = true`, elimina token
- [ ] Agregar mutation `requestEmailVerification` en `AuthResolver` (requiere `@UseGuards(JwtAuthGuard)`)
- [ ] Crear `src/auth/auth.controller.ts` con endpoint REST `GET /auth/verify-email?token=` que redirige tras verificar
- [ ] Registrar `AuthController` en `AuthModule`
- [ ] Modificar `AuthService.register()` para enviar email de verificacion automaticamente si el usuario tiene email (fire-and-forget)
- [ ] Agregar variables de entorno: `EMAIL_VERIFICATION_TTL` (default 24h)

## Fase 3: Restablecimiento de Contrasena

- [ ] Agregar metodo `requestPasswordReset(email)` a `AuthService` — busca usuario por email, genera token `reset:<token>`, envia email. Retorna `true` siempre (prevencion de enumeracion)
- [ ] Agregar metodo `resetPasswordWithToken(token, newPassword)` a `AuthService` — valida token, hashea nueva contrasena (doble SHA-256 existente), actualiza BD, invalida sesiones
- [ ] Agregar mutation `requestPasswordReset(email: String!)` en `AuthResolver` (publica, sin auth)
- [ ] Crear DTO `ResetPasswordInput` con campos `token` y `newPassword`
- [ ] Agregar mutation `resetPassword(resetInput: ResetPasswordInput!)` en `AuthResolver` (publica, sin auth)
- [ ] Agregar variable de entorno: `PASSWORD_RESET_TTL` (default 1h)

## Fase 4: Seguridad y Testing

- [ ] Aplicar throttle a `requestPasswordReset` y `requestEmailVerification` usando decorador `@Throttle` del ThrottlerModule existente
- [ ] Escribir tests unitarios para `AuthService`: `sendVerificationEmail`, `verifyEmailToken`, `requestPasswordReset`, `resetPasswordWithToken`
- [ ] Escribir tests unitarios para `MailService`: verificar llamadas a `mailerService.sendMail` con contexto correcto
- [ ] Escribir test e2e: flujo completo registro -> verificacion de email
- [ ] Escribir test e2e: flujo completo solicitud de reset -> reset de contrasena
- [ ] Verificar que el envio de email no bloquea el registro (fire-and-forget)
- [ ] Verificar que tokens expirados son rechazados correctamente
- [ ] Verificar invalidacion de sesiones tras reset de contrasena
