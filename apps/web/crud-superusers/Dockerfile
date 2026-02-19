FROM node:20-alpine AS builder

WORKDIR /app

COPY apps/web/crud-superusers/package*.json ./
RUN npm install

COPY apps/web/crud-superusers/tsconfig.server.json ./
COPY apps/web/crud-superusers/src/server ./src/server
RUN npm run build

FROM node:20-alpine

WORKDIR /app

COPY --from=builder /app/node_modules ./node_modules
COPY --from=builder /app/dist ./dist

ENV NODE_ENV=production
ENV PORT=3002
ENV BACKEND_URL=http://backend-service:3001

EXPOSE 3002

CMD ["node", "dist/index.js"]
