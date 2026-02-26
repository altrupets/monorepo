# Changelog - Web Apps

All notable changes to the web applications (crud-superusers, b2g) will be documented in this file.

## [Unreleased]

### Fixed
- **CDN Inertia.js**: Corregida la URL del script de Inertia.js que devolvía 404. Ahora usa `@inertiajs/vue3@2.3.16/dist/index.js`
- **ES Modules**: Cambiado de UMD a ES Modules usando `<script type="importmap">` y `<script type="module">` para Vue e Inertia
- **Kustomize paths**: Corregidos los paths relativos en `k8s/overlays/dev/web-*/kustomization.yaml` de `../../base/` a `../../../base/`

### Changed
- **Build IDs**: Los scripts de build ahora incluyen timestamp en los tags de imagen:
  - Anterior: `localhost/altrupets-web-crud-superusers:dev`
  - Nuevo: `localhost/altrupets-web-crud-superusers:20260226-071500` (tagueado también como `dev`)
- **Build scripts**:
  - `infrastructure/scripts/build-web-images-minikube.sh`
  - `infrastructure/scripts/build-backend-image-minikube.sh`

### Added
- **Deployment annotations**: Agregada anotación `build.id: dev` en los deployments de Kubernetes para tracking

## [2026-02-25]

### Added
- Initial setup for crud-superusers web application
- Initial setup for b2g web application
- Server-side rendering with Express
- Inertia.js integration for SPA navigation
