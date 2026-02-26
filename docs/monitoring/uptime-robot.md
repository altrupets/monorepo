# UptimeRobot Configuration

## Endpoints para Monitoreo

Para monitorear servicios locales desde UptimeRobot, necesitas exponerlos públicamente. Opciones:

### Opción 1: ngrok (Desarrollo Local)
```bash
ngrok http 3001
# Obtén URL pública y agrégala a UptimeRobot
```

### Opción 2: GitHub Actions Workflow
El workflow `.github/workflows/uptime.yml` puede crear monitors cuando tengas dominios públicos.

## Monitores Recomendados

| Servicio | URL | Tipo |
|----------|-----|------|
| Backend Health | `https://tu-dominio/health` | HTTP |
| Backend GraphQL | `https://tu-dominio/graphql` | HTTP |
| Web B2G | `https://tu-dominio-b2g/` | HTTP |

## Configuración Manual

1. Ve a https://uptimerobot.com
2. Login con tu cuenta
3. Agregar Monitor:
   - **Type**: HTTP(s)
   - **URL**: Tu dominio público
   - **Keyword**: Buscar "ok" o "healthy" en response
   - **Interval**: 5 minutos

## Alertas

Configurar alertas en UptimeRobot:
- Email notifications
- SMS (plan paid)
- Webhooks para Slack/Discord

## GitHub Secrets

El workflow `.github/workflows/uptime.yml` obtiene los secrets directamente de Infisical.

Solo se necesita configurar un secret en GitHub:
- `INFISICAL_TOKEN`: Machine Identity de Infisical (generar en Settings > Machine Identities)

Los secrets disponibles en Infisical:
- `UPTIMEROBOT_API_KEY`
- `BACKEND_DOMAIN`
