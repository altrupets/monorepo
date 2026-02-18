# ⚙️ Configuración

## Variables de Entorno

### Archivo .env

Crea un archivo `.env` en la raíz del proyecto:

```bash
cp .env.example .env
```

### Variables Requeridas

```env
# Backend
DATABASE_URL=postgresql://user:pass@localhost:5432/altrupets
REDIS_URL=redis://localhost:6379
JWT_SECRET=your-secret-key

# Mobile
API_URL=https://api.altrupets.com
ENVIRONMENT=development
```

## Configuración de Firebase

1. Crea un proyecto en [Firebase Console](https://console.firebase.google.com)
2. Descarga `google-services.json` para Android
3. Descarga `GoogleService-Info.plist` para iOS

## Configuración de AWS (Opcional)

```bash
# Configurar AWS CLI
aws configure

# Configurar credenciales
export AWS_ACCESS_KEY_ID=your-key
export AWS_SECRET_ACCESS_KEY=your-secret
```

## Ejecución

```bash
# Backend
cd apps/backend
npm run start:dev

# Mobile
cd apps/mobile
flutter run
```
