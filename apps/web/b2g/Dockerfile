# Stage 1: Build Flutter Web
# CI context is monorepo root (.), file is ./apps/web/b2g/Dockerfile
FROM ghcr.io/cirruslabs/flutter:stable AS build

WORKDIR /app
COPY apps/web/b2g/pubspec.yaml apps/web/b2g/pubspec.lock* ./
RUN flutter pub get
COPY apps/web/b2g/ .
RUN flutter build web --release

# Stage 2: Serve with nginx
FROM nginx:alpine
COPY --from=build /app/build/web /usr/share/nginx/html
COPY apps/web/b2g/nginx.conf /etc/nginx/conf.d/default.conf
EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]
