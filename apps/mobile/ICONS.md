# App Icons - AltruPets Mobile

Este documento explica cómo se gestionan los iconos de la aplicación móvil.

## Isotipo

El isotipo de AltruPets (`isotipo.svg`) se encuentra en:
- **Fuente original**: `style-dictionary/isotipo.svg`
- **Copia en mobile**: `apps/mobile/assets/isotipo.svg`

## Generación Automática de Iconos

Los iconos de la app (launcher icons) se generan **automáticamente** cuando ejecutas el script de lanzamiento.

### Cuándo se Generan

El script `launch_flutter_debug.sh` verifica automáticamente si:
1. Los iconos no existen
2. El archivo `isotipo.svg` es más reciente que los iconos generados

Si cualquiera de estas condiciones es verdadera, regenera los iconos automáticamente.

### Comandos que Generan Iconos

Todos estos comandos verifican y generan iconos si es necesario:

```bash
make dev-mobile-launch-desktop
make dev-mobile-launch-emulator
make dev-mobile-launch-device
```

O directamente:

```bash
cd apps/mobile
./launch_flutter_debug.sh -l  # Desktop
./launch_flutter_debug.sh -e  # Emulator
./launch_flutter_debug.sh -d  # Device
```

### Plataformas Soportadas

Los iconos se generan para:
- ✅ Android (todos los tamaños: mdpi, hdpi, xhdpi, xxhdpi, xxxhdpi)
- ✅ iOS (todos los tamaños requeridos)
- ✅ Web (favicon)
- ✅ Linux
- ✅ macOS
- ✅ Windows

### Configuración

La configuración está en `pubspec.yaml`:

```yaml
flutter_launcher_icons:
  android: true
  ios: true
  image_path: "assets/isotipo.svg"
  min_sdk_android: 21
  web:
    generate: true
    image_path: "assets/isotipo.svg"
  windows:
    generate: true
    image_path: "assets/isotipo.svg"
  macos:
    generate: true
    image_path: "assets/isotipo.svg"
  linux:
    generate: true
    image_path: "assets/isotipo.svg"
```

## Actualizar Iconos

Si cambias el isotipo en `style-dictionary/isotipo.svg`:

1. Copia el nuevo isotipo:
   ```bash
   cp style-dictionary/isotipo.svg apps/mobile/assets/
   ```

2. Los iconos se regenerarán automáticamente la próxima vez que ejecutes la app:
   ```bash
   make dev-mobile-launch-desktop
   ```

3. Commit los cambios generados en:
   - `android/app/src/main/res/mipmap-*/`
   - `ios/Runner/Assets.xcassets/AppIcon.appiconset/`
   - `web/icons/`
   - `linux/`, `macos/`, `windows/`

## Notas Importantes

### Requisitos para Android

Para compilar en Android, necesitas tener Java configurado:

```bash
# Verificar si Java está instalado
java -version

# Si no está instalado, instalar OpenJDK 17
sudo apt install openjdk-17-jdk

# Configurar JAVA_HOME (agregar a ~/.bashrc o ~/.zshrc)
export JAVA_HOME=/usr/lib/jvm/java-17-openjdk-amd64
export PATH=$JAVA_HOME/bin:$PATH

# Recargar configuración
source ~/.bashrc
```

### Linux Desktop - Modo Debug

En modo debug de Flutter en Linux, el icono de ventana NO aparece en la barra de título. Esto es una limitación conocida de Flutter en Linux:

- El ejecutable de debug es temporal y no tiene el icono embebido
- `window_manager.setIcon()` no funciona correctamente en debug mode
- El icono SÍ aparecerá cuando compiles en modo release

Para ver el icono en Linux, necesitas compilar en modo release:

```bash
cd apps/mobile
flutter build linux --release
./build/linux/x64/release/bundle/altrupets
```

O crear un paquete .deb/.rpm que incluya el icono en el desktop entry.

### Android/iOS

Los iconos se generan correctamente y aparecen en el launcher del dispositivo, tanto en debug como en release.

### Web

El favicon se genera en `web/favicon.png` y `web/icons/`.

### Windows/macOS

Similar a Linux, el icono puede no aparecer en modo debug pero sí en release builds.

## Archivos Generados

### Android
- `android/app/src/main/res/mipmap-mdpi/ic_launcher.png` (48x48)
- `android/app/src/main/res/mipmap-hdpi/ic_launcher.png` (72x72)
- `android/app/src/main/res/mipmap-xhdpi/ic_launcher.png` (96x96)
- `android/app/src/main/res/mipmap-xxhdpi/ic_launcher.png` (144x144)
- `android/app/src/main/res/mipmap-xxxhdpi/ic_launcher.png` (192x192)

### iOS
- `ios/Runner/Assets.xcassets/AppIcon.appiconset/` (múltiples tamaños)

### Web
- `web/icons/Icon-192.png`
- `web/icons/Icon-512.png`
- `web/favicon.png`

### Desktop
- `linux/`, `macos/`, `windows/` (iconos específicos de cada plataforma)

## Referencias

- [flutter_launcher_icons package](https://pub.dev/packages/flutter_launcher_icons)
- [Material Design - Product Icons](https://material.io/design/iconography/product-icons.html)
- [iOS Human Interface Guidelines - App Icon](https://developer.apple.com/design/human-interface-guidelines/app-icons)
