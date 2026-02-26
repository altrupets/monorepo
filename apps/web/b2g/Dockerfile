FROM node:20-alpine AS builder

WORKDIR /app

COPY apps/web/b2g/package*.json ./
RUN npm install

COPY apps/web/b2g/vite.config.ts ./
COPY apps/web/b2g/tsconfig.json ./
COPY apps/web/b2g/tsconfig.node.json ./
COPY apps/web/b2g/index.html ./
COPY apps/web/b2g/src ./src

RUN npm run build:client

COPY apps/web/b2g/tsconfig.server.json ./
COPY apps/web/b2g/src/server ./src/server
RUN npm run build:server

FROM node:20-alpine

WORKDIR /app

COPY --from=builder /app/node_modules ./node_modules
COPY --from=builder /app/dist ./dist

ENV NODE_ENV=production
ENV PORT=3003
ENV BACKEND_URL=http://backend-service:3001

EXPOSE 3003

CMD ["node", "dist/index.js"]
