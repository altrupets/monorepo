FROM node:20-alpine AS builder

WORKDIR /app

# Copy monorepo structure to preserve relative paths
COPY style-dictionary ./style-dictionary
COPY apps/web/shared ./apps/web/shared
COPY apps/web/crud-superusers/package*.json ./apps/web/crud-superusers/

WORKDIR /app/apps/web/crud-superusers
RUN npm install

# Copy source files
COPY apps/web/crud-superusers .
RUN npm run build && npm prune --omit=dev

FROM node:20-alpine

WORKDIR /app
ENV NODE_ENV=production
ENV PORT=3002
ENV BACKEND_URL=http://backend-service:3001

COPY --from=builder /app/apps/web/crud-superusers/node_modules ./node_modules
COPY --from=builder /app/apps/web/crud-superusers/dist ./dist
COPY --from=builder /app/apps/web/crud-superusers/package*.json ./

EXPOSE 3002

CMD ["node", "dist/server/index.js"]
