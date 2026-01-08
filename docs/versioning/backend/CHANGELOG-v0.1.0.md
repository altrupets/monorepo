# Changelog - Version 0.1.0 (Initial Development)

All notable changes to the AltruPets Backend will be documented in this file.

## [0.1.0] - 2026-01-06

### Added
- **Monorepo Structure**: Reorganized project into an `apps/` directory for microservices and mobile.
- **User Management Service**:
  - Bootstrapped with NestJS and TypeScript.
  - Implemented GraphQL API using Apollo Server (Code-First).
  - Integrated PostgreSQL using TypeORM with Repository/Adapter pattern.
  - Implemented Redis/Valkey caching using `@nestjs/cache-manager`.
  - Added Health Checks via REST `/health` endpoint.
  - Implemented JWT-based Authentication and Role-Based Access Control (RBAC).
  - Integrated Static Analysis (ESLint, Prettier) with 100% clean check.
  - Added environment configuration support via `.env`.

### Changed
- Transitioned `user-management-service` from REST to GraphQL for all primary auth/user operations.
- Refactored `AuthService` to be stateless (12-Factor App aligned).

### Removed
- Legacy REST `AuthController`.
