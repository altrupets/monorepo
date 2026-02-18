FROM node:20-alpine AS builder

WORKDIR /app

# Copy monorepo structure to preserve relative paths
COPY style-dictionary ./style-dictionary
COPY apps/web/shared ./apps/web/shared
COPY apps/web/b2g/package*.json ./apps/web/b2g/

WORKDIR /app/apps/web/b2g
RUN npm install

# Copy source files
COPY apps/web/b2g .
RUN npm run build && npm prune --omit=dev

FROM node:20-alpine

WORKDIR /app
ENV NODE_ENV=production
ENV PORT=3003
ENV BACKEND_URL=http://backend-service:3001

COPY --from=builder /app/apps/web/b2g/node_modules ./node_modules
COPY --from=builder /app/apps/web/b2g/dist ./dist
COPY --from=builder /app/apps/web/b2g/package*.json ./

EXPOSE 3003

CMD ["node", "dist/server/index.js"]
