# Propuesta: Verificacion de Correo y Restablecimiento de Contrasena

**Change ID**: `auth-email-password`
**Linear**: T1-6 / ALT-16
**Sprint**: 3 (v0.5.0 - Value Delivery)
**Tamano**: S (horas)
**Journey**: J1 (Registro y Autenticacion)
**Dependencia**: T0-3 (Done)

---

## Que

Implementar dos flujos complementarios en el modulo de autenticacion del backend NestJS:

1. **Verificacion de correo electronico**: Al registrarse, el usuario recibe un enlace de verificacion por email. Hasta que no verifique, la bandera `isVerified` permanece en `false`.
2. **Restablecimiento de contrasena**: Flujo "Olvide mi contrasena" que envia un enlace seguro con token temporal para establecer una nueva contrasena.

Ambos flujos utilizan tokens firmados con HMAC-SHA256, almacenados en Redis (cache existente), con TTL configurable.

## Por que

- El campo `isVerified` ya existe en la entidad `User` pero nunca se pone en `true` — ningun flujo de verificacion esta implementado.
- El registro actual (`AuthService.register`) crea usuarios con `isVerified: false` sin mecanismo para cambiar ese estado.
- Sin restablecimiento de contrasena, cualquier usuario que olvide su clave queda bloqueado permanentemente.
- Sprint 3 del roadmap incluye explicitamente "Auth complementario (password reset, verificacion email)".
- Es prerequisito para que otros journeys (J4 subsidios, J5 adopcion) confien en la identidad verificada del usuario.

## Alcance

### Incluido

- Integracion de `@nestjs-modules/mailer` con plantillas Handlebars
- Mutation GraphQL `requestEmailVerification` y endpoint REST `GET /auth/verify-email?token=...`
- Mutation GraphQL `requestPasswordReset` y mutation `resetPassword`
- Plantillas de email en espanol (verificacion + reset)
- Tokens seguros en Redis con expiracion configurable
- Rate limiting en endpoints de solicitud (reutiliza ThrottlerModule existente)

### Excluido

- 2FA / TOTP (mencionado como TODO en auth.service.ts, sera un change separado)
- Verificacion por SMS
- Cambio de contrasena estando logueado (puede hacerse como mejora posterior)
- Configuracion de proveedor SMTP en produccion (se documenta pero se usa Ethereal/Mailtrap en dev)

## Riesgo

- **Bajo**: El modulo de auth ya esta maduro (JWT, refresh tokens, rate limiting, RBAC). Solo se agregan flujos nuevos sin modificar los existentes.
- **Configuracion SMTP**: Requiere variables de entorno para el proveedor de email. En desarrollo se usa preview con Ethereal.
