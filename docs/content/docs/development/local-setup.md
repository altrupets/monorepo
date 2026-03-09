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

## Windows + Podman Desktop + WSL2 Ubuntu 24.04

### Modelo recomendado para este repo en Windows

En Windows, este repo puede operar con la siguiente topologia:

- `Podman Desktop` instalado en Windows
- una sola distro `Ubuntu-24.04` en `WSL2`
- sin recrear `podman-machine-default`

### Instalacion de la distro

```powershell
wsl.exe --install Ubuntu-24.04 --name altrupets-ubuntu --version 2 --vhd-size 50GB --no-launch
```

### Configuracion exacta de recursos

Crear `%UserProfile%\.wslconfig` con:

```ini
[wsl2]
processors=8
memory=16GB
swap=4GB
```

Aplicar la configuracion:

```powershell
wsl.exe --shutdown
```

### Alineacion con la configuracion del repo

Esta VM queda alineada con la referencia usada en `infrastructure/scripts/start-minikube.sh`:

```bash
minikube start --driver=podman --cpus=8 --memory=16384 --disk-size=50g
```

### Objetivo

Mantener una sola VM Linux para desarrollo local en Windows y conservar `Podman Desktop` como host del entorno.

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
