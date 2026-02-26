# Changelog - Documentación AltruPets

Todos los cambios notables en la documentación del proyecto AltruPets serán documentados en este archivo.

El formato está basado en [Keep a Changelog](https://keepachangelog.com/es-ES/1.0.0/),
y este proyecto adhiere a [Semantic Versioning](https://semver.org/lang/es/).

## [Unreleased]

### Fixed - 2026-02-26

#### fetch_stitch.sh - Path fix

- Corregido path de salida duplicado (`stitch_assets/stitch_assets/` → `stitch_assets/`)

**Archivos modificados:**
- `stitch_assets/fetch_stitch.sh`

#### infisical-sync.sh - Stitch config

- Corregido `sync_stitch_env()` para sincronizar `GOOGLE_CLOUD_PROJECT` y `STITCH_PROJECT_ID` en lugar de `STITCH_API_KEY`
- Actualizado `setup_stitch()` para guiar configuración OAuth en lugar de API key

**Archivos modificados:**
- `infrastructure/scripts/infisical-sync.sh`

### Changed - 2026-02-26

#### Stitch Assets Fetcher - Migración a OAuth

- Script `stitch_assets/fetch_stitch.sh` ahora usa OAuth de gcloud en lugar de API key
- Eliminado `STITCH_API_KEY` de `.env` (ya no es necesario)
- Agregado `STITCH_PROJECT_ID` como variable requerida en `.env`
- Removido Stitch MCP de `mcp.json` (ya no se usa remote MCP)
- Validación obligatoria de `GOOGLE_CLOUD_PROJECT` y `STITCH_PROJECT_ID`

**Archivos modificados:**
- `.env` - Removido STITCH_API_KEY, agregado STITCH_PROJECT_ID
- `mcp.json` - Eliminado entry "stitch"
- `stitch_assets/fetch_stitch.sh` - Migrado a OAuth, validaciones actualizadas
- `Makefile` - Actualizadas descripciones de targets dev-stitch-*

**Secrets para Infisical:**
- `GOOGLE_CLOUD_PROJECT=344341424155`
- `STITCH_PROJECT_ID=9064173060952920822`

### Added - 2026-02-25

#### Terraform Environments para OVHCloud

- Creados environments Terraform para QA, Staging y Prod
- QA y Staging: OVHCloud Kubernetes + self-managed PostgreSQL
- Prod: OVHCloud Kubernetes + OVH Managed PostgreSQL
- Integracion con Infisical para secrets (proyecto: altrupets para dev/qa/stage, altrupets-prod para prod)
- Script `infrastructure/scripts/deploy-terraform.sh` para despliegue automatizado
- Comandos Makefile: `qa-terraform-deploy`, `stage-terraform-deploy`, `prod-terraform-deploy`
- Production siempre requiere aprobacion manual

**Archivos agregados:**
- `infrastructure/terraform/environments/qa/` - Configuracion QA
- `infrastructure/terraform/environments/staging/` - Configuracion Staging
- `infrastructure/terraform/environments/prod/` - Configuracion Production
- `infrastructure/scripts/deploy-terraform.sh` - Script de despliegue

**Archivos modificados:**
- `Makefile` - Agregados targets qa-terraform-*, stage-terraform-*, prod-terraform-*
- `infrastructure/terraform/README.md` - Documentacion actualizada

#### Documentacion OVHCloud CLI y Terraform

- Actualizado `skills/cicd/ovhcloud/SKILL.md` con:
  - Instalacion de OVHCloud CLI (ovhcloud-cli)
  - Comandos para crear clusters Kubernetes
  - Configuracion de Terraform provider
  - Recursos: ovh_cloud_project_kube, nodepool, PostgreSQL
  - Regiones y flavors disponibles

**Archivos modificados:**
- `skills/cicd/ovhcloud/SKILL.md` - Agregado CLI y Terraform completo

#### ✨ Configuración de direnv para el proyecto

- Agregado `.envrc` para activar automáticamente el venv con pre-commit
- Agregado hook de direnv a `~/.bashrc`

**Archivos agregados:**
- `.envrc` - Activa .venv al entrar al proyecto

### Fixed - 2026-02-25

#### 🐛 Bugfix: Admin Server ejecuta siempre todos los comandos

- Admin server ahora ejecuta TODOS los comandos de deployment siempre
- Ya no detecta si minikube está corriendo para hacer "modo rápido"
- Cada comando se loggea por separado en el admin server log

**Archivos modificados:**
- `scripts/backend_admin_server.py` - Eliminado chequeo de minikube

#### 🐛 Bugfix: Admin Server y Mobile Launch

- **Problema 1**: El admin server (`backend_admin_server.py`) ejecutaba siempre el one-liner completo en lugar de usar la variable correcta según el estado de minikube
- **Problema 2**: Los logs del admin server no se mostraban en el mobile log
- **Problema 3**: `make dev-gateway-start` fallaba con exit code 2 (el comando `pkill` se colgaba)

**Soluciones implementadas:**

1. `backend_admin_server.py`:
   - Corregido bug: ahora usa la variable correcta (`commands_to_run`)
   - Añadido streaming de output por comando
   - Cada comando se ejecuta secuencialmente y loggea inicio/resultado

2. `Makefile`:
   - Cambiado `pkill -f "kubectl port-forward"` por `ps aux | grep | awk | kill`
   - El `pkill` se colga indefinidamente cuando no hay procesos que coincidan

**Archivos modificados:**
- `scripts/backend_admin_server.py` - Streaming de comandos y bugfix
- `Makefile` - Fix para pkill en dev-gateway-start y dev-gateway-stop

### Changed - 2025-02-18

#### 🔄 Cambio a Renderizado Estático de Diagramas Mermaid

- Reemplazado `mkdocs-panzoom-plugin` por `mkdocs-mermaid2-plugin`
- Los diagramas Mermaid ahora se renderizan como imágenes estáticas durante el build
- Solución más confiable que no depende de JavaScript en el navegador
- Garantiza que los diagramas se visualicen correctamente en todos los navegadores
- Configuración simplificada con Mermaid v10.6.1

**Razón del cambio:** El renderizado dinámico con JavaScript presentaba problemas
de compatibilidad. El renderizado estático garantiza que los diagramas siempre
se visualicen correctamente.

**Archivos modificados:**
- `docs/requirements.txt` - Reemplazado panzoom por mermaid2-plugin
- `docs/mkdocs.yml` - Configuración del plugin mermaid2
- `docs/content/stylesheets/altrupets-custom.css` - Estilos mantenidos para diagramas

### Added - 2025-02-18

#### 🔍 Funcionalidad de Zoom/Pan para Diagramas Mermaid

- Implementado plugin `mkdocs-panzoom-plugin` para interacción con diagramas SVG
- Configuración optimizada para experiencia de usuario fluida:
  - Click para hacer zoom (acercar)
  - Arrastrar para mover (pan) cuando está ampliado
  - Scroll del mouse para zoom continuo
  - Zoom speed: 0.1 (transiciones suaves)
  - Pan speed: 10 (respuesta rápida)
  - Rango de zoom: 0.5x a 3.0x
- Estilos CSS personalizados con branding AltruPets:
  - Cursor `grab` cuando se puede arrastrar
  - Cursor `grabbing` durante el arrastre
  - Hint visual al hacer hover: "💡 Click para hacer zoom, arrastra para mover"
  - Transiciones suaves en todas las interacciones
  - Soporte completo para modo claro y oscuro
- Aplicado automáticamente a todos los diagramas Mermaid (9 diagramas en total):
  - 6 diagramas en `docs/mobile/features.md`
  - 2 diagramas en `docs/mobile/architecture.md`
  - 1 diagrama en `docs/mobile/widgetbook.md`

#### 📦 Dependencias

- Agregado `mkdocs-panzoom-plugin>=0.1.0` a `requirements.txt`

#### 🎨 Estilos

- Nuevos estilos CSS en `altrupets-custom.css`:
  - Estados de cursor para pan & zoom
  - Transiciones suaves para transformaciones SVG
  - Hint text contextual con opacidad animada
  - Integración completa con paleta de colores AltruPets

#### 🔧 Configuración

- Actualizado `mkdocs.yml` con configuración del plugin panzoom:
  - Selector `.mermaid` para aplicar a todos los diagramas
  - Habilitado zoom on click, pan y zoom
  - Parámetros de velocidad y límites optimizados

### Technical Details

**Archivos modificados:**
- `docs/requirements.txt` - Agregada dependencia del plugin
- `docs/mkdocs.yml` - Configuración del plugin panzoom
- `docs/content/stylesheets/altrupets-custom.css` - Estilos para interacción

**Beneficios:**
- Mejor legibilidad de diagramas complejos
- Experiencia de usuario mejorada para explorar arquitectura
- Navegación intuitiva sin necesidad de abrir imágenes en nueva pestaña
- Consistencia visual con el branding de AltruPets

**Compatibilidad:**
- Funciona en todos los navegadores modernos
- Soporte completo para dispositivos táctiles
- Accesible mediante teclado (zoom con +/-)
- Rendimiento optimizado sin impacto en tiempo de carga

---

## [1.0.0] - 2025-02-17

### Added

#### 📱 Documentación Mobile Completa

- Creado `docs/mobile/getting-started.md` con guía de inicio
- Creado `docs/mobile/launch-script.md` con documentación del script de lanzamiento
- Creado `docs/mobile/widgetbook.md` con flujo de QA de UI design
- Creado `docs/mobile/features.md` con 6 diagramas Mermaid
- Creado `docs/mobile/architecture.md` con 2 diagramas Mermaid
- Actualizado `docs/mobile/index.md` con referencias a nuevos documentos

#### 🎨 Branding AltruPets

- Implementadas variables CSS con paleta completa de colores desde `style-dictionary/tokens.json`
- Tipografías locales Poppins y Lemon Milk integradas
- Gradientes en header y navegación
- Estilos personalizados para todos los componentes de Material for MkDocs

#### 🔧 Configuración

- Actualizado `mkdocs.yml` con navegación completa
- Configurado Material for MkDocs con tema personalizado
- Agregados plugins: search, git-revision-date, git-committers, minify

---

## Notas de Versión

### Convenciones de Versionado

- **MAJOR**: Cambios incompatibles en la estructura de documentación
- **MINOR**: Nuevas secciones o funcionalidades de documentación
- **PATCH**: Correcciones, mejoras menores y actualizaciones de contenido

### Categorías de Cambios

- **Added**: Nuevas funcionalidades o secciones
- **Changed**: Cambios en funcionalidades existentes
- **Deprecated**: Funcionalidades que serán removidas
- **Removed**: Funcionalidades removidas
- **Fixed**: Correcciones de bugs o errores
- **Security**: Cambios relacionados con seguridad

---

**Última actualización:** 18 de febrero de 2025
