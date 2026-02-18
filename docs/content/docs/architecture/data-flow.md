# 📊 Flujo de Datos

## Flujo de Rescate

```
1. Centinela reporta → GraphQL Mutation
2. Geolocalización → Algoritmo de proximidad
3. Auxiliares notificados → Firebase Cloud Messaging
4. Auxiliar acepta → Actualización de estado
5. Rescatista asignado → Workflow de cuidado
6. Caso cerrado → Métricas y trazabilidad
```

## Flujo de Donación

```
1. Donante selecciona amount → Checkout
2. Gateway seleccionado → latam_payments
3. Procesamiento → Pago regional
4. Confirmación → Actualización de estado
5. Notificación → Recibo y trazabilidad
```
