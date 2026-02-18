# 💻 Desarrollo Local

## Quick Start

```bash
# Clonar repositorio
git clone https://github.com/altrupets/altrupets-monorepo.git
cd altrupets-monorepo

# Instalar dependencias
cd apps/mobile && flutter pub get
cd apps/backend && npm install

# Ejecutar desarrollo
flutter run
npm run start:dev
```

## Configuración

Ver [Instalación](../getting-started/installation.md) y [Configuración](../getting-started/setup.md)

## Troubleshooting

### Error de dependencias

```bash
# Limpiar cache de Flutter
flutter clean
flutter pub get

# Reinstalar node_modules
rm -rf node_modules
npm install
```
