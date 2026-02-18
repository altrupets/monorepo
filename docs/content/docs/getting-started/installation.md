# 🚀 Instalación

## Prerrequisitos

### Software Requerido

- **Flutter** 3.x+
- **Dart** 3.x+
- **Node.js** 18+
- **Docker** y **Docker Compose**
- **AWS CLI** (para desarrollo cloud)
- **Terraform** 1.x

### Instalación de Flutter

```bash
# macOS/Linux
git clone https://github.com/flutter/flutter.git -d stable
export PATH="$PATH:$HOME/flutter/bin"

# Verificar instalación
flutter --version
```

### Instalación de Dependencias

```bash
# Instalar Flutter dependencies
cd apps/mobile
flutter pub get

# Instalar Node.js dependencies
cd apps/backend
npm install
```

## Configuración de IDE

### VS Code

Extensiones recomendadas:
- Flutter
- Dart
- Docker
- YAML
- GitLens

### IntelliJ IDEA / WebStorm

- Flutter plugin
- Dart plugin

## Próximo Paso

[Configuración inicial →](./setup.md)
