# 📂 Estructura del Proyecto

```
altrupets-monorepo/
├── apps/
│   ├── backend/           # NestJS + GraphQL
│   │   └── src/
│   │       ├── modules/  # Módulos por dominio
│   │       ├── common/   # Componentes compartidos
│   │       └── config/   # Configuración
│   └── mobile/           # Flutter
│       ├── lib/
│       │   ├── core/    # Código compartido
│       │   │   └── payments/  # 🟢 Paquete de pagos
│       │   ├── features/ # Features
│       │   └── shared/   # Utilidades
│       └── test/        # Tests
├── docs/                 # Documentación MkDocs
│   └── content/
├── infrastructure/       # Terraform
├── skills/              # Agent Skills
└── .github/
    └── workflows/       # CI/CD
```
