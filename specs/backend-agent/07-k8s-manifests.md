# PASO 7: Kubernetes Manifests para Agent en altrupets-dev

## 7.1 Base: `k8s/base/agent/`

### deployment.yaml

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: agent
  labels:
    app: agent
spec:
  replicas: 1
  selector:
    matchLabels:
      app: agent
  template:
    metadata:
      labels:
        app: agent
    spec:
      containers:
        - name: agent
          image: localhost/altrupets-agent:dev
          ports:
            - name: http
              containerPort: 3002
          envFrom:
            - configMapRef:
                name: agent-config
            - secretRef:
                name: agent-secret
          readinessProbe:
            httpGet:
              path: /health
              port: http
            initialDelaySeconds: 10
            periodSeconds: 10
          livenessProbe:
            httpGet:
              path: /health
              port: http
            initialDelaySeconds: 30
            periodSeconds: 20
          resources:
            requests:
              cpu: 100m
              memory: 256Mi
            limits:
              cpu: 500m
              memory: 512Mi
```

### service.yaml

```yaml
apiVersion: v1
kind: Service
metadata:
  name: agent-service
  labels:
    app: agent
spec:
  type: ClusterIP
  selector:
    app: agent
  ports:
    - name: http
      port: 3002
      targetPort: http
```

### configmap.yaml

```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: agent-config
data:
  NODE_ENV: "development"
  PORT: "3002"
  FALKORDB_HOST: "falkordb-service.altrupets-dev.svc.cluster.local"
  FALKORDB_PORT: "6379"
  BACKEND_GRAPHQL_URL: "http://backend-service.altrupets-dev.svc.cluster.local:3001/graphql"
  LANGFUSE_BASE_URL: "https://cloud.langfuse.com"
  LLM_MODEL: "gpt-4o"
```

### secret.yaml

```yaml
apiVersion: v1
kind: Secret
metadata:
  name: agent-secret
type: Opaque
stringData:
  JWT_SECRET: "super-secret-altrupets-key-2026"
  FALKORDB_PASSWORD: "altrupets-falkor-dev-2026"
  OPENAI_API_KEY: "sk-REPLACE-ME"
  LANGFUSE_PUBLIC_KEY: "pk-lf-REPLACE-ME"
  LANGFUSE_SECRET_KEY: "sk-lf-REPLACE-ME"
  ZEP_API_KEY: ""
  # En prod estos vienen de Infisical
```

### httproute.yaml

```yaml
apiVersion: gateway.networking.k8s.io/v1
kind: HTTPRoute
metadata:
  name: agent-graphql-route
spec:
  parentRefs:
    - name: dev-gateway
      namespace: altrupets-dev
  hostnames:
    - "agent.altrupets.local"
    - "localhost"
  rules:
    - matches:
        - path:
            type: PathPrefix
            value: /agent/graphql
      backendRefs:
        - name: agent-service
          port: 3002
```

### kustomization.yaml

```yaml
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization
resources:
  - configmap.yaml
  - secret.yaml
  - deployment.yaml
  - service.yaml
  - httproute.yaml
```

## 7.2 Dev Overlay: `k8s/overlays/dev/agent/`

### patch-deployment.yaml

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: agent
spec:
  replicas: 1
  template:
    spec:
      containers:
        - name: agent
          image: localhost/altrupets-agent:dev
          imagePullPolicy: Never
          envFrom:
            - secretRef:
                name: agent-secret
          env:
            - name: NODE_ENV
              value: "development"
```

### kustomization.yaml

```yaml
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization

namespace: altrupets-dev

resources:
  - ../../../base/agent

patches:
  - path: patch-deployment.yaml
```

## 7.3 ArgoCD Application

### k8s/argocd/applications/agent-dev.yaml

```yaml
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: altrupets-agent-dev
  namespace: argocd
  finalizers:
    - resources-finalizer.argocd.argoproj.io
spec:
  project: altrupets-dev
  source:
    repoURL: https://github.com/altrupets/monorepo.git
    targetRevision: main
    path: k8s/overlays/dev/agent
  destination:
    server: https://kubernetes.default.svc
    namespace: altrupets-dev
  syncPolicy:
    automated:
      prune: true
      selfHeal: true
    syncOptions:
      - CreateNamespace=true
```
