# ArgoCD Manifests

- `projects/altrupets-dev-project.yaml`: Project para entorno dev.
- `applications/backend-dev.yaml`: ejemplo estático de Application (edita `repoURL` antes de aplicar).
- `app-of-apps.yaml`: ejemplo App-of-Apps (requiere `repoURL` válido).

Para bootstrap automatizado usa:

```bash
REPO_URL=https://github.com/<org>/<repo>.git ./infrastructure/scripts/setup-argocd-dev.sh
```
