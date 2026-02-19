# 🚀 Getting Started

Guía completa para configurar y ejecutar AltruPets Mobile en tu entorno de desarrollo.

## Prerrequisitos

### Software Requerido

| Software | Versión Mínima | Propósito |
|----------|----------------|----------|
| Flutter SDK | 3.10.4+ | Framework |
| Dart SDK | 3.0+ | Incluido con Flutter |
| Android Studio | 2023.1+ | IDE y Android SDK |
| Xcode | 14.0+ | Solo macOS, para iOS |
| VS Code | Latest | IDE alternativo |

### Verificar Instalación

```bash
# Verificar que Flutter está correctamente instalado
flutter doctor -v

# Output esperado:
# [✓] Flutter (Channel stable, 3.10.x)
# [✓] Android toolchain
# [✓] Xcode (solo macOS)
# [✓] Chrome
# [✓] Android Studio
```

### Extensiones Recomendadas (VS Code)

- **Flutter** - Dart-Code.flutter
- **Dart** - Dart-Code.dart-code
- **Riverpod Snippets** - robert-brunhage.flutter-riverpod-snippets
- **Error Lens** - usernamehw.errorlens

## Instalación

### 1. Clonar el Repositorio

```bash
git clone https://github.com/altrupets/monorepo.git
cd monorepo/apps/mobile
```

### 2. Instalar Dependencias

```bash
flutter pub get
```

### 3. Generar Código

El proyecto usa Freezed y JSON Serializable para generar código:

```bash
# Generar una vez
flutter pub run build_runner build --delete-conflicting-outputs

# O en modo watch (regenera automáticamente al guardar)
flutter pub run build_runner watch --delete-conflicting-outputs
```

!!! warning "Archivos Generados"
    Los archivos `*.freezed.dart` y `*.g.dart` son generados automáticamente.
    **No los edites manualmente** - tus cambios se perderán.

### 4. Generar Localizaciones

```bash
flutter gen-l10n
```

Esto genera `lib/l10n/app_localizations.dart` desde los archivos `.arb`.

## Configuración del Backend

### URL del Backend

Edita `lib/core/utils/constants.dart`:

```dart
class AppConstants {
  // Desarrollo local
  static const String baseUrl = 'http://localhost:4000';
  
  // Para emulador Android (localhost no funciona)
  // static const String baseUrl = 'http://10.0.2.2:4000';
  
  // Para dispositivo físico Android (usa tu IP local)
  // static const String baseUrl = 'http://192.168.1.100:4000';
  
  // Staging
  // static const String baseUrl = 'https://api-staging.altrupets.com';
  
  // Producción
  // static const String baseUrl = 'https://api.altrupets.com';
}
```

### Variables de Entorno (Opcional)

Para múltiples ambientes, considera usar `flutter_dotenv`:

```bash
# .env.development
API_URL=http://localhost:4000

# .env.staging
API_URL=https://api-staging.altrupets.com

# .env.production
API_URL=https://api.altrupets.com
```

## Ejecutar la Aplicación

### Listar Dispositivos Disponibles

```bash
flutter devices

# Output ejemplo:
# 3 connected devices:
# Pixel 6 (mobile)      • emulator-5554      • android-arm64
# macOS (desktop)       • macos              • darwin-x64
# Chrome (web)          • chrome             • web-javascript
```

### Ejecutar en Modo Debug

```bash
# Dispositivo por defecto
flutter run

# Dispositivo específico
flutter run -d emulator-5554
flutter run -d chrome

# Con verbose logging
flutter run -v
```

### Ejecutar en Modo Release

```bash
# Android
flutter run --release

# iOS (requiere perfil de provisión)
flutter run --release -d <ios-device-id>
```

### Hot Reload vs Hot Restart

| Acción | Atajo | Uso |
|--------|-------|-----|
| Hot Reload | `r` | Cambios en UI, preserva estado |
| Hot Restart | `R` | Reinicia app, pierde estado |
| Quit | `q` | Salir de flutter run |

## Build para Producción

### Android

```bash
# APK (para distribución directa)
flutter build apk --release
# Output: build/app/outputs/flutter-apk/app-release.apk

# App Bundle (para Play Store)
flutter build appbundle --release
# Output: build/app/outputs/bundle/release/app-release.aab

# Con ofuscación (recomendado para producción)
flutter build appbundle --release --obfuscate --split-debug-info=build/debug-info
```

### iOS

```bash
# Build para archivo (requiere Xcode)
flutter build ios --release

# Luego en Xcode:
# Product > Archive > Distribute App
```

### Firmar Builds

#### Android

Crea `android/key.properties`:

```properties
storePassword=<password>
keyPassword=<password>
keyAlias=upload
storeFile=<path-to-keystore>/upload-keystore.jks
```

#### iOS

Configura en Xcode:
1. Signing & Capabilities
2. Selecciona tu Team
3. Configura Bundle Identifier

## Testing

### Ejecutar Tests

```bash
# Todos los tests
flutter test

# Test específico
flutter test test/features/auth/auth_provider_test.dart

# Con coverage
flutter test --coverage

# Ver reporte de coverage
genhtml coverage/lcov.info -o coverage/html
open coverage/html/index.html
```

### Estructura de Tests

```
test/
├── features/
│   ├── auth/
│   │   ├── auth_provider_test.dart
│   │   └── auth_repository_test.dart
│   └── profile/
│       └── profile_provider_test.dart
├── core/
│   ├── graphql_client_test.dart
│   └── failures_test.dart
└── widget_test.dart
```

## Comandos Útiles

### Limpieza y Mantenimiento

```bash
# Limpiar caché y builds
flutter clean

# Regenerar pubspec.lock
rm pubspec.lock && flutter pub get

# Actualizar dependencias
flutter pub upgrade

# Ver dependencias desactualizadas
flutter pub outdated
```

### Análisis de Código

```bash
# Ejecutar analyzer
flutter analyze

# Formatear código
dart format lib/

# Fix automático de issues
dart fix --apply
```

### Debugging

```bash
# Ver logs del dispositivo
flutter logs

# Capturar screenshot
flutter screenshot

# Abrir DevTools
flutter pub global activate devtools
devtools
```

## Troubleshooting

### Error: "SocketException: Connection refused"

**Causa**: El backend no está corriendo o la URL es incorrecta.

**Solución**:
1. Verifica que el backend esté corriendo en `localhost:4000`
2. Si usas emulador Android, cambia a `10.0.2.2:4000`
3. Si usas dispositivo físico, usa la IP de tu máquina

### Error: "Could not find generator 'freezed'"

**Causa**: build_runner no está instalado o caché corrupto.

**Solución**:
```bash
flutter clean
flutter pub get
flutter pub run build_runner build --delete-conflicting-outputs
```

### Error: "Gradle build failed"

**Solución**:
```bash
cd android
./gradlew clean
cd ..
flutter clean
flutter pub get
flutter run
```

### Error: "CocoaPods not installed" (macOS)

**Solución**:
```bash
sudo gem install cocoapods
cd ios
pod install
cd ..
```

### Hot Reload no funciona

**Causa**: Cambios en código nativo o archivos de configuración.

**Solución**: Usa Hot Restart (`R`) o reinicia completamente con `flutter run`.

