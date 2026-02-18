# 💻 Desarrollo Local

## Quick Start

```bash
# Clonar repositorio
git clone https://github.com/altrupets/altrupets-monorepo.git
cd altrupets-monorepo

# Instalar dependencias
cd apps/mobile && flutter pub get
cd apps/backend && npm install

# Ejecutar desarrollo
flutter run
npm run start:dev
```

## Minikube (Desarrollo Local con Kubernetes)

### Configuración Obligatoria

Minikube debe configurarse con **Podman driver** y **containerd runtime**:

```bash
# Instalar Podman
sudo apt install podman

# Configurar modo rootless
minikube config set rootless true

# Iniciar cluster
minikube start --driver=podman --container-runtime=containerd

# Verificar
minikube status
kubectl get nodes
```

### ¿Por qué Podman + containerd?

| Driver | Problema |
|--------|----------|
| Docker | Crea archivos `.csm_*` y `.s3_*` con permisos de root |
| Podman (rootless) + containerd | Sin archivos huérfanos, sin sudo |

### Deploy Local

```bash
# Deploy completo
make dev-minikube-deploy

# Deploy de micro-frontends
make dev-superusers-deploy
make dev-b2g-deploy

# Ver servicios
kubectl get pods -n altrupets-dev
```

## Configuración

Ver [Instalación](../getting-started/installation.md) y [Configuración](../getting-started/setup.md)

## Troubleshooting

### Error de dependencias

```bash
# Limpiar cache de Flutter
flutter clean
flutter pub get

# Reinstalar node_modules
rm -rf node_modules
npm install
```

### Archivos huérfanos de Minikube

Si aparecen archivos `.csm_*` o `.s3_*` con permisos de root:

```bash
# Eliminar archivos huérfanos
sudo rm -f .csm_* .s3_*

# Reiniciar Minikube con configuración correcta
minikube delete
minikube config set rootless true
minikube start --driver=podman --container-runtime=containerd
```
