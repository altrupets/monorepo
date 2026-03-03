# PASO 4: Desplegar FalkorDB en namespace altrupets-dev

## 4.1 Base Manifests

Crear: `k8s/base/falkordb/`

### deployment.yaml

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: falkordb
  labels:
    app: falkordb
spec:
  replicas: 1
  selector:
    matchLabels:
      app: falkordb
  template:
    metadata:
      labels:
        app: falkordb
    spec:
      containers:
        - name: falkordb
          image: docker.io/falkordb/falkordb:latest
          ports:
            - name: redis
              containerPort: 6379
          args:
            - "--requirepass"
            - "$(FALKORDB_PASSWORD)"
          env:
            - name: FALKORDB_PASSWORD
              valueFrom:
                secretKeyRef:
                  name: falkordb-secret
                  key: FALKORDB_PASSWORD
          resources:
            requests:
              cpu: 100m
              memory: 256Mi
            limits:
              cpu: 500m
              memory: 1Gi
          volumeMounts:
            - name: falkordb-data
              mountPath: /data
          readinessProbe:
            exec:
              command: ["redis-cli", "-a", "$(FALKORDB_PASSWORD)", "ping"]
            initialDelaySeconds: 5
            periodSeconds: 10
          livenessProbe:
            exec:
              command: ["redis-cli", "-a", "$(FALKORDB_PASSWORD)", "ping"]
            initialDelaySeconds: 15
            periodSeconds: 20
      volumes:
        - name: falkordb-data
          persistentVolumeClaim:
            claimName: falkordb-pvc
```

### service.yaml

```yaml
apiVersion: v1
kind: Service
metadata:
  name: falkordb-service
  labels:
    app: falkordb
spec:
  type: ClusterIP
  selector:
    app: falkordb
  ports:
    - name: redis
      port: 6379
      targetPort: redis
```

### pvc.yaml

```yaml
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: falkordb-pvc
spec:
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: 2Gi
```

### secret.yaml

```yaml
apiVersion: v1
kind: Secret
metadata:
  name: falkordb-secret
type: Opaque
stringData:
  FALKORDB_PASSWORD: "altrupets-falkor-dev-2026"
  # En prod esto viene de Infisical, no hardcoded
```

### kustomization.yaml

```yaml
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization
resources:
  - secret.yaml
  - pvc.yaml
  - deployment.yaml
  - service.yaml
```

## 4.2 Dev Overlay

Crear: `k8s/overlays/dev/falkordb/`

### kustomization.yaml

```yaml
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization

namespace: altrupets-dev

resources:
  - ../../../base/falkordb
```

## 4.3 Desplegar

```bash
kubectl apply -k k8s/overlays/dev/falkordb --server-side
kubectl rollout status deployment/falkordb -n altrupets-dev --timeout=120s

# Verificar:
kubectl get pods -n altrupets-dev -l app=falkordb
```
