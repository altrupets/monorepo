# Changelog

All notable changes to the AltruPets Backend will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.0.0] - 2025-02-19

### Added
- Initial stable release of AltruPets Backend
- **Security Scanner** - Dedicated Docker image for DevSecOps scanning
  - Separate container with Trivy, Checkov, tfsec, Trufflehog
  - Runs as Kubernetes Jobs/CronJobs
  - See `infrastructure/docker/security-scanner/CHANGELOG.md` for details
- GraphQL API with Apollo Server 5.x
- REST API endpoints for admin and B2G panels
- JWT authentication with passport-jwt
- TypeORM integration with PostgreSQL
- Inertia.js support for server-driven SPA
- Health checks endpoint at `/health`
- Docker containerization with multi-stage builds
- Kubernetes deployment manifests

### Changed
- **BREAKING**: Migrated from Express 4.x to Express 5.2.1
  - Express 5 restored `app.router` which was deprecated in Express 4.19+
  - No custom adapter needed for NestJS 11 compatibility
- **BREAKING**: Replaced `nestjs-inertia` with `@lapc506/nestjs-inertia@1.0.0`
  - Fixed broken entrypoint (`dist/index.js` → `dist/src/index.js`)
  - Updated peer dependencies for NestJS 11.x compatibility
  - Express 5.x compatible
  - Published at: https://www.npmjs.com/package/@lapc506/nestjs-inertia

### Dependencies
| Package | Version |
|---------|---------|
| @nestjs/common | ^11.0.1 |
| @nestjs/core | ^11.0.1 |
| @nestjs/platform-express | ^11.0.1 |
| express | ^5.2.1 |
| @lapc506/nestjs-inertia | ^1.0.0 |
| @apollo/server | ^5.2.0 |
| typeorm | ^0.3.19 |
| pg | ^8.16.3 |

### Infrastructure
- Minikube-based local development environment
- Kubernetes deployments for backend, web-superusers, web-b2g
- PostgreSQL StatefulSet
- Gateway API with HTTPRoutes
- **cert-manager** module for Let's Encrypt TLS certificates
  - DNS-01 challenge via Cloudflare
  - Staging and Production ClusterIssuers
  - Terraform module at `infrastructure/terraform/modules/kubernetes/cert-manager`
- **Infisical** integration for secrets management
  - CLI sync script at `infrastructure/scripts/infisical-sync.sh`
  - Removed legacy `seed-superuser-minikube.sh` script
- **TLS/HTTPS** support in Gateway API module
  - Configurable HTTPS listener
  - NodePort service for both HTTP and HTTPS

### Known Issues
- `@types/express` v5.x may have incomplete type definitions for some Express 5 features
- Some npm packages may still have peer dependency warnings for Express 5

### Migration Notes

#### From pre-1.0.0 to 1.0.0

1. **Update package dependencies:**
   ```bash
   npm install express@^5.2.1 @lapc506/nestjs-inertia@^1.0.0
   ```

2. **No code changes required** for most applications using:
   - Standard NestJS patterns
   - Inertia.js middleware
   - GraphQL resolvers
   - TypeORM repositories

3. **If using wildcards in routes** (not used in this project):
   ```typescript
   // Express 4
   app.use('*', handler)

   // Express 5
   app.use('{*splat}', handler)
   ```

4. **If using res.send(status)** (not used in this project):
   ```typescript
   // Express 4
   res.send(200)

   // Express 5
   res.sendStatus(200)
   ```

---

## Release Checklist

### v1.0.0 Readiness

| Criteria | Status |
|----------|--------|
| Core functionality stable | ✅ |
| Authentication working | ✅ |
| GraphQL API functional | ✅ |
| Database connectivity | ✅ |
| Environment configuration | ✅ |
| Docker builds | ✅ |
| Kubernetes deployments | ✅ |
| Health checks | ✅ |
| Error handling | ✅ |
| Security (JWT, validation) | ✅ |
| Unit tests | ✅ 1/1 passing |
| E2E tests | ✅ 1/1 passing |
| Security audit | ✅ 0 vulnerabilities |
| Documentation | ✅ This CHANGELOG |

### Testing

**Unit tests:**
```bash
make dev-backend-test
# Output: 1/1 passing
```

**E2E tests:**
```bash
make dev-backend-test-e2e
# Output: 1/1 passing
```

> Note: E2E tests use a lightweight TestModule without database dependencies for fast execution.

### Pre-release Tasks

- [x] Security audit: `npm audit` (0 vulnerabilities)
- [x] Unit tests passing (1/1)
- [x] E2E tests passing (1/1)
- [x] Verify all GraphQL queries/mutations
- [x] Test authentication flow end-to-end
- [x] Review database migration scripts (3 migrations, all with up/down)
- [x] Update API documentation (`apps/backend/API.md`)
- [x] Infisical secrets sync (`infrastructure/scripts/infisical-sync.sh`)
- [x] cert-manager Terraform module
- [x] Gateway API TLS/HTTPS support
- [ ] Create release tag

---

## Infrastructure as Code

### Terraform Modules

| Module | Path | Description |
|--------|------|-------------|
| cert-manager | `infrastructure/terraform/modules/kubernetes/cert-manager` | Let's Encrypt TLS certificates |
| gateway-api | `infrastructure/terraform/modules/kubernetes/gateway-api` | NGINX Gateway Fabric with HTTPS support |
| postgres-minikube | `infrastructure/terraform/modules/database/postgres-minikube` | PostgreSQL StatefulSet |

### K8s Manifests

| File | Description |
|------|-------------|
| `infrastructure/k8s/cert-manager/cluster-issuer.yaml` | Let's Encrypt staging + prod issuers |
| `infrastructure/k8s/cert-manager/certificate.yaml` | Certificate for `*.altrupets.app` |

### Scripts

| Script | Description |
|--------|-------------|
| `infrastructure/scripts/infisical-sync.sh` | Sync secrets from Infisical to Kubernetes |
| `infrastructure/scripts/infisical-sync.sh --cli` | Sync using CLI (no operator required) |

---

## Future Roadmap

### v1.1.0 (Planned)
- [ ] Redis caching integration
- [ ] Rate limiting
- [ ] OpenAPI/Swagger documentation

### v1.2.0 (Planned)
- [ ] WebSocket support
- [ ] Real-time notifications
- [ ] Background job queue

### v2.0.0 (Future)
- [ ] Microservices architecture
- [ ] Event-driven communication
- [ ] Multi-tenancy support
