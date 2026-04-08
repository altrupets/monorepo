# Stage 1: Build Flutter Web
# CI context is monorepo root (.), file is ./apps/web/b2g/Dockerfile
FROM ghcr.io/cirruslabs/flutter:stable AS build

WORKDIR /monorepo
COPY packages/altrupets_ui/ packages/altrupets_ui/
COPY apps/web/b2g/ apps/web/b2g/
WORKDIR /monorepo/apps/web/b2g
RUN flutter pub get && flutter build web --release

# Stage 2: Serve with nginx
FROM nginx:alpine
COPY --from=build /monorepo/apps/web/b2g/build/web /usr/share/nginx/html
COPY apps/web/b2g/nginx.conf /etc/nginx/conf.d/default.conf
EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]
