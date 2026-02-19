# Changelog - Security Scanner

All notable changes to the AltruPets Security Scanner will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.0.0] - 2025-02-19

### Added
- Initial release of Security Scanner container
- Dockerfile with all security scanning tools pre-installed
- Python 3.12-slim base image for minimal attack surface
- Integrated security tools:
  - **Trivy** v0.69.1 - Container and filesystem vulnerability scanner
  - **tfsec** v1.28.14 - Terraform security scanner
  - **Checkov** v3.2.504 - Infrastructure as Code security scanner
  - **Trufflehog** v2.2.1 - Secret detection tool
  - **Safety** - Python dependency vulnerability scanner
  - **Bandit** - Python code security analyzer
- Node.js 20.x for npm audit support
- Flutter/Dart SDK for dart analyze support
- Kubernetes Job/CronJob ready architecture
- Report generation to `/reports` directory

### Architecture Decision

**Why a separate Docker image for security scanning?**

This project follows the **separation of concerns** principle:

1. **Backend Container** (`apps/backend/Dockerfile`):
   - Contains ONLY what's needed to run the application in production
   - Uses `node:20-alpine` for minimal size (~150MB)
   - No security tools included (reduces attack surface)
   - Fast build and deployment times

2. **Security Scanner Container** (`infrastructure/docker/security-scanner/Dockerfile`):
   - Contains ALL security scanning tools
   - Runs as Kubernetes Jobs/CronJobs
   - Scans source code, dependencies, images, and IaC
   - NOT deployed to production environments

**Benefits:**
- ✅ Smaller production images (security principle: minimal attack surface)
- ✅ Faster backend deployments
- ✅ Security tools isolated from production workloads
- ✅ Can be scheduled independently (CronJobs)
- ✅ Single source of truth for security tooling versions

**Anti-pattern (what we DON'T do):**
- ❌ Installing security tools in backend Dockerfile
- ❌ Mixing runtime dependencies with scanning tools
- ❌ Exposing security tools in production containers

### Usage

#### Build the image
```bash
docker build -t altrupets/security-scanner:1.0.0 \
  -f infrastructure/docker/security-scanner/Dockerfile .
```

#### Run locally
```bash
docker run --rm \
  -v $(pwd):/workspace \
  -v $(pwd)/.security-reports:/reports \
  altrupets/security-scanner:1.0.0 all
```

#### Deploy as Kubernetes CronJob
```bash
kubectl apply -f k8s/base/security-scanner/cronjob.yaml
```

### Scan Types

| Scan | Tool | Description |
|------|------|-------------|
| `deps` | npm audit, safety | Dependency vulnerabilities |
| `sast` | dart analyze, eslint, bandit | Static code analysis |
| `secrets` | trufflehog | Secret detection |
| `container` | trivy | Container image vulnerabilities |
| `iac` | tfsec, checkov | Infrastructure as Code security |
| `all` | All tools | Complete security scan |

### Dependencies

| Tool | Version | Purpose |
|------|---------|---------|
| Python | 3.12-slim | Base runtime |
| Trivy | 0.69.1 | Container/filesystem scanning |
| tfsec | 1.28.14 | Terraform security |
| Checkov | 3.2.504 | IaC security (multi-cloud) |
| Trufflehog | 2.2.1 | Secret detection |
| Node.js | 20.x | npm audit support |
| Flutter | stable | Dart analysis |

### Infrastructure

- Kubernetes Job for on-demand scans
- Kubernetes CronJob for scheduled scans (daily at 2 AM)
- ServiceAccount with read-only cluster access
- ConfigMap for scanner configuration
- PersistentVolumeClaim for report storage

### Known Limitations

- Flutter SDK adds ~500MB to image size (required for dart analyze)
- Trivy database updates require internet connectivity
- Some tools may have false positives (tune with config files)

### Future Roadmap

#### v1.1.0 (Planned)
- [ ] SARIF output format for GitHub Security tab
- [ ] Slack/Discord notifications for critical findings
- [ ] Baseline comparison (only report new vulnerabilities)

#### v1.2.0 (Planned)
- [ ] Integration with Datadog Security Monitoring
- [ ] Custom policy enforcement (fail on HIGH/CRITICAL)
- [ ] Automated PR creation for dependency updates

#### v2.0.0 (Future)
- [ ] AI-powered vulnerability prioritization
- [ ] Auto-remediation suggestions
- [ ] Integration with SIEM platforms

---

**Última actualización:** 19 de febrero de 2025
