# AltruPets Web CRUD

Aplicación web simple para verificar que los datos de usuarios actualizados desde la app Flutter se persisten correctamente en el backend.

## Desarrollo

```bash
npm install
npm run dev
```

La aplicación estará disponible en `http://localhost:5173`

## Funcionalidades

- Lista todos los usuarios del sistema
- Muestra detalles completos de cada usuario
- Permite verificar que los datos actualizados desde Flutter se guardaron correctamente
- Muestra la fecha de última actualización para verificar cambios

## Configuración

El endpoint GraphQL está configurado en `src/services/graphql.ts` y apunta a `http://localhost:3001/graphql` por defecto.
