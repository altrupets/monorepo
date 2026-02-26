FROM node:20-alpine AS builder

WORKDIR /app

COPY apps/web/crud-superusers/package*.json ./
RUN npm install

COPY apps/web/crud-superusers/vite.config.ts ./
COPY apps/web/crud-superusers/tsconfig.json ./
COPY apps/web/crud-superusers/tsconfig.node.json ./
COPY apps/web/crud-superusers/index.html ./
COPY apps/web/crud-superusers/src ./src

RUN npm run build:client

COPY apps/web/crud-superusers/tsconfig.server.json ./
COPY apps/web/crud-superusers/src/server ./src/server
RUN npm run build:server

FROM node:20-alpine

WORKDIR /app

COPY --from=builder /app/node_modules ./node_modules
COPY --from=builder /app/dist ./dist

ENV NODE_ENV=production
ENV PORT=3002
ENV BACKEND_URL=http://backend-service:3001

EXPOSE 3002

CMD ["node", "dist/index.js"]
