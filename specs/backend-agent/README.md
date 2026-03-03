# Agent AI Service — Spec & Setup Guide

> Microservicio NestJS independiente con GraphQL propio para IA de matching de rescatistas.
> Integra LangGraph, Zep (FalkorDB), Langfuse. Deployable en Minikube (dev) y OVHCloud (QA/STAGE/PROD).

## Documentos

| Archivo | Contenido |
|---------|-----------|
| [01-minikube-makefile.md](./01-minikube-makefile.md) | PASO 1: Minikube + namespace + integración Makefile |
| [02-turborepo-pnpm.md](./02-turborepo-pnpm.md) | PASO 2: Turborepo + pnpm workspaces |
| [03-agent-nestjs.md](./03-agent-nestjs.md) | PASO 3: Crear /apps/agent (NestJS + GraphQL) |
| [04-falkordb-k8s.md](./04-falkordb-k8s.md) | PASO 4: FalkorDB en namespace altrupets-dev |
| [05-langgraph-zep-langfuse.md](./05-langgraph-zep-langfuse.md) | PASO 5: LangGraph + Zep + Langfuse integration |
| [06-dockerfile.md](./06-dockerfile.md) | PASO 6: Dockerfile multi-stage |
| [07-k8s-manifests.md](./07-k8s-manifests.md) | PASO 7: K8s manifests (Deployment, Service, Secret) |
| [08-build-load.md](./08-build-load.md) | PASO 8: Build + load en Minikube con Podman |
| [09-dev-workflow.md](./09-dev-workflow.md) | PASO 9: Workflow desarrollo local |
| [10-security-mobile.md](./10-security-mobile.md) | PASO 10: Seguridad mobile → agent |
| [11-cloud-practices.md](./11-cloud-practices.md) | PASO 11: Mejores prácticas y cloud |

## Arquitectura

```
Mobile (Flutter) ──Bearer JWT──→ Agent (NestJS :4000/graphql)
                                    ├── LangGraph (StateGraph)
                                    ├── FalkorDB (:6379) ← graph + memory
                                    ├── Langfuse (observability)
                                    └── Backend (:3001/graphql) ← usuarios, capturas
```

## Quick Start

```bash
make dev-minikube-deploy && make dev-terraform-deploy
pnpm install
make dev-agent-build && make dev-agent-deploy
make dev-agent-port-forward   # http://localhost:4000/graphql
```
