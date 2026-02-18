# Infisical Setup for AltruPets

## Estado actual

```
✅ Infisical CLI instalado (v0.43.56)
✅ Kubernetes Operator instalado en Minikube
⏳ Pendiente: Login y configuración de secrets
```

## Pasos para completar la configuración

### Paso 1: Login en Infisical

```bash
infisical login
```

Selecciona **Infisical Cloud** y autoriza en el navegador.

### Paso 2: Crear proyecto

```bash
cd apps/backend
infisical init
```

O manualmente en [app.infisical.com](https://app.infisical.com):
1. Crea un nuevo proyecto llamado `altrupets`
2. Crea un ambiente `dev`

### Paso 3: Agregar secrets en Infisical

En tu proyecto `altrupets` > ambiente `dev`, agrega:

| Secret Key | Secret Value |
|------------|--------------|
| `DB_USERNAME` | `dev_demo_admin` |
| `DB_PASSWORD` | `kKQU?Fv1N2S%0?f=\B+` |
| `DB_NAME` | `altrupets_dev_database` |
| `JWT_SECRET` | `your-secret-key-here` |
| `ENV_NAME` | `dev` |

### Paso 4: Crear Machine Identity (Token)

1. Ve a **Project Settings** > **Machine Identities**
2. Crea una nueva identidad:
   - Name: `altrupets-dev-operator`
   - Environment: `dev`
   - Permissions: Read
3. Copia el **Client ID** y **Client Secret**

### Paso 5: Obtener Project ID

```bash
infisical project list
```

Copia el Project ID del proyecto `altrupets`.

### Paso 6: Crear secret de credenciales

```bash
kubectl create secret generic infisical-operator-credentials \
  --namespace infisical-operator-system \
  --from-literal=CLIENT_ID=<tu-client-id> \
  --from-literal=CLIENT_SECRET=<tu-client-secret>
```

### Paso 7: Actualizar infisical-secrets.yaml

Edita `infrastructure/infisical/infisical-secrets.yaml` y reemplaza `<PROJECT_ID>` con tu Project ID.

### Paso 8: Aplicar CRDs

```bash
kubectl apply -f infrastructure/infisical/infisical-secrets.yaml
```

### Paso 9: Verificar sincronización

```bash
# Ver estado de InfisicalSecrets
kubectl get infisicalsecrets -A

# Ver secret creado
kubectl get secrets backend-secret -n altrupets-dev -o yaml
```

## Comandos útiles

```bash
# Verificar estado del operator
kubectl get pods -n infisical-operator-system

# Ver logs del operator
kubectl logs -n infisical-operator-system -l app.kubernetes.io/name=secrets-operator

# Ver secrets sincronizados
kubectl get infisicalsecrets -A

# Describir InfisicalSecret
kubectl describe infisicalsecret infisical-backend-secret -n altrupets-dev
```

## Flujo de desarrollo

Con el operator configurado:

1. Cambias un secret en Infisical Cloud
2. El operator lo detecta automáticamente (cada 60s)
3. Actualiza el K8s secret correspondiente
4. Reinicia el deployment para aplicar cambios:

```bash
kubectl rollout restart deployment/backend -n altrupets-dev
```

## URLs

- Dashboard: https://app.infisical.com
- Documentación: https://infisical.com/docs/integrations/platforms/kubernetes/overview
