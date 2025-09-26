# AltruPets

Aplicación móvil desarrollada en Flutter que conecta a amantes de los animales para combatir el maltrato animal y ayudar a animales abandonados en Costa Rica. La aplicación permite interponer denuncias, coordinar rescates y gestionar casas cuna para animales rescatados, sirviendo como una plataforma única para la colaboración entre ciudadanos, organizaciones, gobiernos locales y empresas.

## Objetivo

Crear una red colaborativa que agilice los procesos de rescate animal y mejore la respuesta ante situaciones de maltrato, conectando a todos los actores del ecosistema de protección animal de manera eficiente y transparente para combatir el maltrato animal y ayudar a animales abandonados en Costa Rica.

## Arquitectura del Sistema

El sistema está diseñado como una arquitectura distribuida con separación clara de responsabilidades:

### Frontend (Aplicación Móvil Flutter)
- Interfaz de usuario e interacciones
- Captura y validación básica de datos
- Gestión de estado local y caché
- Funcionalidad offline básica
- Comunicación con APIs del backend
- Manejo de notificaciones push
- Geolocalización y mapas
- Captura de fotos y multimedia

### Backend (API/Servicios)
- Lógica de negocio compleja
- Autenticación y autorización (RBAC)
- Procesamiento de pagos
- Algoritmos de machine learning y detección de anomalías
- Gestión de base de datos y persistencia
- Integración con servicios externos
- Cumplimiento regulatorio y KYC
- Generación de reportes y análisis
- Gestión de notificaciones push
- Procesamiento de imágenes y archivos

## Funcionalidades Principales

### 🔐 Sistema de Usuarios y Roles
- **Registro individual y organizacional** con control de acceso basado en roles (RBAC)
- **Roles disponibles**: Sentinela, Rescatista, Donante, Veterinario, Administrador
- **Gestión organizacional** con jerarquías y permisos específicos
- **Administración gubernamental** para supervisión jurisdiccional

### 📢 Sistema de Denuncias
- **Denuncias anónimas** sin necesidad de registro
- **Geolocalización automática** de incidentes
- **Captura de evidencia fotográfica**
- **Código de seguimiento** para consultas posteriores

### 🚨 Red de Rescate
- **Sentinelas**: Identifican y reportan casos de animales en riesgo
- **Rescatistas**: Reciben notificaciones y coordinan rescates
- **Búsqueda por proximidad** (radio de 10km, expandible a 25km)
- **Chat interno** para coordinación en tiempo real

### 🏠 Gestión de Casas Cuna
- **Inventario de animales** bajo cuidado
- **Registro médico** y seguimiento de tratamientos
- **Gestión de disponibilidad** para adopción
- **Control de capacidad** automático

### 🩺 Red de Veterinarios
- **Registro de profesionales** y clínicas especializadas
- **Tarifas preferenciales** para rescate animal
- **Solicitudes de atención** con priorización por urgencia
- **Historial médico** completo de tratamientos

### 💰 Sistema de Donaciones
- **Donaciones monetarias** con múltiples métodos de pago
- **Donaciones de insumos** según necesidades específicas
- **Suscripciones recurrentes** y crowdfunding
- **Transparencia financiera** con reportes detallados

### 📊 Gestión Financiera
- **Registro de gastos** por categoría (alimentación, veterinaria, etc.)
- **Control de ingresos** por donaciones
- **Reportes contables** exportables (PDF, Excel)
- **Auditoría completa** de transacciones

### ⭐ Sistema de Reputación
- **Calificaciones mutuas** entre usuarios (1-5 estrellas)
- **Comentarios y feedback** sobre servicios
- **Reputación dinámica** con expiración de calificaciones (3 meses)
- **Detección de patrones sospechosos**

### 🔒 Seguridad y Cumplimiento
- **Cumplimiento PCI DSS** para procesamiento de pagos
- **Controles KYC** según montos de donación
- **Encriptación de datos** sensibles
- **Detección de anomalías** con machine learning

### 🌍 Geolocalización
- **GPS automático** para reportes e incidentes
- **Búsqueda por proximidad** de rescatistas y veterinarios
- **Mapas integrados** para navegación
- **Funcionalidad offline** con sincronización posterior

### 💬 Comunicación
- **Chat interno** entre usuarios involucrados en casos
- **Compartir ubicación** y fotos en tiempo real
- **Notificaciones push** personalizadas
- **Centro de notificaciones** interno

### 🏛️ Modelo SaaS Gubernamental
- **Multi-tenancy** para gobiernos locales
- **Personalización institucional** (logos, colores, políticas)
- **Mediación de conflictos** y supervisión
- **Reportes de transparencia** y métricas públicas

## Integración de Pagos

### ONVOPay
- **Procesamiento seguro** de tarjetas de crédito/débito
- **Tokenización** para pagos recurrentes
- **WebView seguro** sin almacenamiento de datos sensibles
- **Webhooks** para confirmación de transacciones

## Tecnologías

### Frontend (Flutter)
- Flutter/Dart
- Provider/Riverpod para gestión de estado
- Hive/SQLite para almacenamiento local
- HTTP/Dio para APIs
- Firebase Messaging para notificaciones
- Google Maps para geolocalización
- WebSocket para chat en tiempo real

### Backend
- Node.js/Express o Python/FastAPI
- PostgreSQL/MongoDB para base de datos
- Redis para caché y sesiones
- JWT para autenticación
- WebSockets para comunicación en tiempo real
- Firebase Admin SDK para notificaciones
- AWS S3 para almacenamiento de archivos
- Docker para containerización

## Estructura del Proyecto

```
centinelasalrescate/
├── mobile/                 # Aplicación Flutter
│   ├── lib/
│   ├── android/
│   ├── ios/
│   └── pubspec.yaml
├── backend/               # API y servicios
│   ├── src/
│   ├── config/
│   ├── tests/
│   └── package.json
├── shared/                # Código compartido
│   ├── models/           # Modelos de datos
│   ├── constants/        # Constantes compartidas
│   └── utils/           # Utilidades comunes
├── docs/                 # Documentación
├── scripts/              # Scripts de deployment
└── docker-compose.yml    # Para desarrollo local
```

## Cumplimiento Regulatorio

- **SUGEF**: Cumplimiento de regulaciones financieras
- **KYC**: Conocimiento del cliente según montos
- **PCI DSS**: Estándares de seguridad para pagos
- **Protección de datos**: Encriptación y privacidad
- **Auditoría**: Trazabilidad completa de operaciones

## Licencia

Este proyecto está licenciado bajo los términos especificados en el archivo LICENSE.
