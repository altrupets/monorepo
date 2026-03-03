# PASO 6: Dockerfile para /apps/agent (Multi-Stage)

## apps/agent/Dockerfile

```dockerfile
# === Stage 1: Build ===
FROM node:22-alpine AS builder

RUN corepack enable && corepack prepare pnpm@latest --activate

WORKDIR /app

# Copiar package manifests primero (cache de dependencias)
COPY package.json pnpm-lock.yaml* ./
RUN pnpm install --frozen-lockfile 2>/dev/null || pnpm install

# Copiar source y compilar
COPY . .
RUN pnpm run build

# === Stage 2: Production ===
FROM node:22-alpine AS production

RUN corepack enable && corepack prepare pnpm@latest --activate

WORKDIR /app

ENV NODE_ENV=production

COPY --from=builder /app/package.json /app/pnpm-lock.yaml* ./
RUN pnpm install --prod --frozen-lockfile 2>/dev/null || pnpm install --prod

COPY --from=builder /app/dist ./dist

EXPOSE 4000

USER node

CMD ["node", "dist/main"]
```

## apps/agent/.dockerignore

```
node_modules
dist
.env.local
*.md
.git
```
