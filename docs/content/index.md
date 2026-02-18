# AltruPets - Documentación del Proyecto

Bienvenido a la documentación técnica de **AltruPets**, una plataforma cloud-native de protección animal para toda Latinoamérica.

## 🌐 Sitio Principal

**URL**: [altrupets.github.io/altrupets-monorepo/](https://altrupets.github.io/altrupets-monorepo/)

## 📚 Secciones de Documentación

### Quick Links

| Sección | Descripción |
|---------|-------------|
| [Arquitectura](./docs/architecture/overview.md) | Arquitectura del sistema y diseño técnico |
| [Tecnologías](./docs/architecture/technologies.md) | Stack tecnológico completo |
| [Desarrollo](./docs/development/local-setup.md) | Guía de configuración y desarrollo local |
| [Despliegue](./docs/deployment/kubernetes.md) | Estrategias de despliegue en producción |
| [latam_payments](./docs/packages/latam-payments-package.md) | Paquete de pagos para LATAM |

---

## 🚀 Estado del Proyecto

### ✅ Completado

- [x] Arquitectura base del monorepo
- [x] Backend con NestJS + GraphQL
- [x] Frontend Flutter con Clean Architecture
- [x] Infraestructura Kubernetes
- [x] Pipeline CI/CD con GitHub Actions
- [x] Sistema de pagos LATAM (latam_payments)

### 📋 Roadmap

- [ ] Despliegue a producción
- [ ] Integración con pasarelas de pago regionales
- [ ] Sistema de notificaciones push
- [ ] Module Federation para micro-frontends
- [ ] Métricas y observabilidad

---

## 📁 Estructura del Proyecto

```
altrupets-monorepo/
├── apps/
│   ├── backend/           # Backend NestJS + GraphQL
│   └── mobile/           # App Flutter
├── docs/                 # Documentación MkDocs
│   └── content/          # Archivos markdown
├── infrastructure/       # Terraform + Kubernetes
├── skills/              # Agent Skills para IA
├── specs/               # Especificaciones técnicas
└── site/                # Salida de GitHub Pages
```

---

## 🔗 Enlaces Relevantes

- **GitHub**: [github.com/altrupets](https://github.com/altrupets)
- **Sitio Web**: [altrupets.com](https://altrupets.com)

---

*Última actualización: Febrero 2026*
