# 📱 AltruPets Mobile

Aplicación móvil multiplataforma desarrollada con **Flutter** para conectar rescatistas de animales, organizaciones de protección animal y adoptantes en Latinoamérica.

## Visión General

AltruPets Mobile es el cliente móvil del ecosistema AltruPets, diseñado con **Clean Architecture** y **Riverpod** para garantizar mantenibilidad, testabilidad y escalabilidad. La aplicación soporta operaciones offline-first, sincronización en segundo plano y un sistema de pagos integrado para donaciones.

## Stack Tecnológico

| Categoría | Tecnología | Versión | Propósito |
|-----------|------------|---------|----------|
| Framework | Flutter | 3.10+ | UI multiplataforma |
| State Management | Riverpod | 2.5.1 | Gestión de estado reactivo |
| Arquitectura | Clean Architecture | - | Separación de concerns |
| Inmutabilidad | Freezed | 2.4.1 | Modelos inmutables y union types |
| Networking | GraphQL | 5.1.2 | Comunicación con backend |
| HTTP Client | Dio | 5.4.0 | Requests REST auxiliares |
| Local Storage | Hive + SQLite | 2.2.3 / 2.3.3 | Persistencia offline |
| Secure Storage | flutter_secure_storage | 9.2.2 | Tokens y datos sensibles |
| Geolocalización | Geolocator | 11.0.0 | Ubicación para rescates |
| Functional | Dartz | 0.10.1 | Either, Option para manejo de errores |

## Estructura del Proyecto

```
apps/mobile/
├── lib/
│   ├── core/                      # Código compartido entre features
│   │   ├── auth/                  # Roles y permisos
│   │   │   └── roles/user_role.dart
│   │   ├── config/                # Configuración de entorno
│   │   │   └── environment_manager.dart
│   │   ├── error/                 # Manejo de errores
│   │   │   ├── exceptions.dart
│   │   │   ├── failures.dart
│   │   │   └── error_logging_observer.dart
│   │   ├── graphql/               # Cliente GraphQL
│   │   │   └── graphql_client.dart
│   │   ├── models/                # Modelos compartidos
│   │   │   ├── user_model.dart
│   │   │   └── organization_model.dart
│   │   ├── network/               # Capa de red
│   │   │   ├── http_client_service.dart
│   │   │   ├── network_info.dart
│   │   │   ├── circuit_breaker.dart
│   │   │   └── interceptors/
│   │   │       ├── auth_interceptor.dart
│   │   │       ├── error_interceptor.dart
│   │   │       ├── logging_interceptor.dart
│   │   │       └── retry_interceptor.dart
│   │   ├── payments/              # SDK de pagos LATAM
│   │   │   ├── latam_payments.dart
│   │   │   ├── domain/
│   │   │   ├── data/gateways/
│   │   │   └── services/
│   │   ├── providers/             # Providers globales
│   │   │   ├── geolocation_provider.dart
│   │   │   ├── navigation_provider.dart
│   │   │   └── registration_provider.dart
│   │   ├── services/              # Servicios de negocio
│   │   │   ├── auth_service.dart
│   │   │   ├── geolocation_service.dart
│   │   │   ├── logging_service.dart
│   │   │   └── onvo_pay_service.dart
│   │   ├── storage/               # Almacenamiento local
│   │   │   ├── app_prefs_store.dart
│   │   │   ├── profile_cache_store.dart
│   │   │   └── secure_storage_service.dart
│   │   ├── sync/                  # Sincronización offline
│   │   │   ├── sync_status_provider.dart
│   │   │   ├── profile_update_queue_store.dart
│   │   │   └── generic_sync_queue_store.dart
│   │   ├── theme/                 # Sistema de diseño
│   │   │   ├── app_colors.dart
│   │   │   ├── app_theme.dart
│   │   │   ├── app_typography.dart
│   │   │   ├── app_motion.dart
│   │   │   ├── theme_provider.dart
│   │   │   ├── token_service.dart
│   │   │   └── design_token_model.dart
│   │   ├── usecases/              # Base de use cases
│   │   │   └── usecase.dart
│   │   ├── utils/                 # Utilidades
│   │   │   └── constants.dart
│   │   └── widgets/               # Widgets reutilizables (Atomic Design)
│   │       ├── atoms/
│   │       ├── molecules/
│   │       └── organisms/
│   │
│   ├── features/                  # Features por dominio
│   │   ├── auth/                  # Autenticación
│   │   ├── home/                  # Dashboard principal
│   │   ├── onboarding/            # Flujo de registro
│   │   ├── organizations/         # Gestión de organizaciones
│   │   ├── profile/               # Perfil de usuario
│   │   ├── rescues/               # Coordinación de rescates
│   │   └── settings/              # Configuración
│   │
│   ├── l10n/                      # Internacionalización
│   │   ├── app_en.arb
│   │   └── app_es.arb
│   │
│   └── main.dart                  # Entry point
│
├── assets/
│   ├── fonts/                     # Tipografías personalizadas
│   │   ├── lemon_milk/
│   │   └── poppins/
│   └── style_dictionary/          # Design tokens exportados
│
├── test/                          # Tests unitarios y de widget
└── pubspec.yaml
```

## Quick Start

```bash
# Clonar e instalar dependencias
git clone https://github.com/altrupets/monorepo.git
cd monorepo/apps/mobile
flutter pub get

# Generar código (Freezed, JSON Serializable)
flutter pub run build_runner build --delete-conflicting-outputs

# Generar localizaciones
flutter gen-l10n

# Ejecutar
flutter run
```

## Características Principales

### 🔐 Autenticación
- Login/Registro con JWT
- Detección automática de token expirado
- Secure storage para credenciales
- Manejo de sesión expirada con redirección

### 🏠 Gestión de Organizaciones
- Búsqueda con filtros avanzados
- Registro de nuevas organizaciones
- Gestión de membresías y roles

### 🐾 Coordinación de Rescates
- Geolocalización en tiempo real
- Notificaciones a rescatistas cercanos
- Historial y seguimiento

### 💳 Sistema de Pagos LATAM
- Múltiples gateways: OnvoPay, Tilopay (CR), Wompi (CO)
- Soporte para SINPE, PSE, tarjetas
- Tokenización segura de tarjetas

### 📴 Offline-First
- Cache local con Hive
- Cola de sincronización para cambios pendientes
- Indicador de estado de sincronización

### 🎨 Design System
- Material 3 con tokens personalizados
- Soporte para modo claro/oscuro
- Tipografías: Lemon Milk (headers) + Poppins (body)

## Documentación

| Documento | Descripción |
|-----------|-------------|
| [Arquitectura](architecture.md) | Clean Architecture, Riverpod patterns, manejo de errores |
| [Getting Started](getting-started.md) | Instalación, configuración, comandos |
| [Features](features.md) | Detalle de cada funcionalidad |
| [Core](core.md) | Servicios compartidos, network, payments, storage |
| [Design System](design-system.md) | Colores, tipografía, tema, widgets |
