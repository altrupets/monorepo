# PASO 9: Workflow de Desarrollo Local

## 9.1 Hot-Reload sin K8s (modo rapido)

```bash
# Terminal 1: Port-forward FalkorDB desde k8s
make dev-falkordb-port-forward

# Terminal 2: Agent en modo watch
make dev-agent-start
# NestJS watch mode en localhost:3002/graphql
```

## 9.2 Deploy Completo en K8s

```bash
# Rebuild y redeploy todo
make dev-agent-build && make dev-agent-deploy
```

## 9.3 Acceder al GraphQL Playground

```bash
# Opcion A: port-forward directo
make dev-agent-port-forward
# abrir http://localhost:3002/graphql

# Opcion B: via Gateway
make dev-gateway-start
# acceder via http://localhost:3001/agent/graphql (si HTTPRoute configurado)
```

## 9.4 Turborepo Dev Paralelo

```bash
# Desde raiz — levanta backend + agent en paralelo con hot-reload
pnpm turbo run dev --filter=@altrupets/backend --filter=@altrupets/agent
```

## 9.5 Quick Start Completo con Agent

```bash
# Full stack con Agent:
make dev-minikube-deploy && make dev-terraform-deploy && make dev-gateway-deploy \
  && make dev-images-build && make dev-agent-deploy && make dev-backend-tf-deploy \
  && make dev-gateway-start
```
