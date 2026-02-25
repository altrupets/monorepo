# Altrupets Mobile

Aplicación Flutter con **Clean Architecture** y **Riverpod** para el proyecto Altrupets.

## 🏗️ Arquitectura

Este proyecto implementa **Clean Architecture** con las siguientes capas:

- **Domain Layer**: Entidades, interfaces de repositorios y casos de uso
- **Data Layer**: Modelos, fuentes de datos y implementaciones de repositorios
- **Presentation Layer**: Providers de Riverpod, páginas y widgets

## 📦 State Management

Utiliza **Riverpod** para la gestión de estado reactiva y compile-time safety.

## 🚀 Comenzar

### Prerrequisitos

- Flutter SDK instalado
- Dart SDK (incluido con Flutter)

### Instalación

```bash
flutter pub get
```

### Generar código

```bash
# Generar archivos Freezed
flutter pub run build_runner build --delete-conflicting-outputs

# Generar localizaciones
flutter gen-l10n
```

### Ejecutar

```bash
flutter run
```

## 📁 Estructura del Proyecto

```
lib/
├── core/               # Capa core (error handling, usecases, network)
├── config/             # Configuración (theme, routes, constants)
├── features/           # Features organizadas por Clean Architecture
│   └── home/
│       ├── domain/     # Domain layer
│       ├── data/       # Data layer
│       └── presentation/ # Presentation layer (Riverpod)
├── l10n/              # Archivos de internacionalización
└── main.dart          # Punto de entrada
```

## 🧪 Testing

```bash
flutter test
```

## 📚 Skills Implementados

- ✅ Clean Architecture
- ✅ Riverpod para state management
- ✅ Freezed para inmutabilidad
- ✅ Internacionalización (i18n)
- ✅ Material 3 theming

---

**Última actualización:** Diciembre 2025
