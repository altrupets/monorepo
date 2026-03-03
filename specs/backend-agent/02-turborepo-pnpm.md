# PASO 2: Instalación de Turborepo con pnpm Workspaces

## 2.1 Instalar pnpm

```bash
corepack enable
corepack prepare pnpm@latest --activate
pnpm --version  # verificar >= 9.x
```

## 2.2 Root package.json

```json
{
  "name": "altrupets-monorepo",
  "version": "1.0.0",
  "private": true,
  "packageManager": "pnpm@9.15.4",
  "scripts": {
    "build": "turbo run build",
    "dev": "turbo run dev",
    "lint": "turbo run lint",
    "test": "turbo run test",
    "agent:dev": "turbo run dev --filter=@altrupets/agent",
    "agent:build": "turbo run build --filter=@altrupets/agent",
    "backend:dev": "turbo run dev --filter=@altrupets/backend",
    "backend:build": "turbo run build --filter=@altrupets/backend"
  },
  "devDependencies": {
    "turbo": "^2.4.0"
  }
}
```

## 2.3 pnpm-workspace.yaml

```yaml
packages:
  - "apps/backend"
  - "apps/agent"
  - "apps/web/*"
```

> **Nota:** Flutter apps (`apps/mobile`, `apps/widgetbook`) NO van en el workspace pnpm — usan pubspec.yaml/Dart.

## 2.4 turbo.json

```json
{
  "$schema": "https://turbo.build/schema.json",
  "globalDependencies": [".env"],
  "globalEnv": ["NODE_ENV"],
  "tasks": {
    "build": {
      "dependsOn": ["^build"],
      "outputs": ["dist/**"],
      "cache": true
    },
    "dev": {
      "dependsOn": ["^build"],
      "cache": false,
      "persistent": true
    },
    "lint": {
      "cache": true
    },
    "test": {
      "cache": true
    },
    "test:e2e": {
      "cache": false,
      "dependsOn": ["build"]
    }
  }
}
```

## 2.5 Root .npmrc

```ini
shamefully-hoist=true
strict-peer-dependencies=false
legacy-peer-deps=true
```

## 2.6 Migrar backend a pnpm

```bash
# Desde la raíz del monorepo:
cd apps/backend
rm -f package-lock.json   # pnpm generará pnpm-lock.yaml en raíz
cd ../..

# Renombrar en apps/backend/package.json:
# "name": "@altrupets/backend"

# Instalar todo desde raíz:
pnpm install
```

## 2.7 Verificar

```bash
pnpm turbo run build --filter=@altrupets/backend
```
