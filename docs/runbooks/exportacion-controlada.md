# Runbook: Exportación Controlada de Datos

Propósito: Ejecutar exportaciones cumpliendo minimización de PII, marca de agua, límites y auditoría.

## 1. Verificación previa
- Caso/Incident/Request ID:
- Motivo y base legal/política:
- Alcance (tablas/campos/tenants) y filtro:
- ¿Hay break-glass activo? Sí/No (referencia a aprobación)

## 2. Preparación
- Usar vistas enmascaradas o datasets anonimizados cuando aplique.
- Configurar marca de agua (destinatario, fecha, finalidad). 
- Definir límites de volumen y particiones por lotes.

## 3. Ejecución
- Ejecutar export usando cuenta de servicio dedicada.
- Registrar checksums por archivo y totales de registros.
- Verificar que no se incluyan PAN/PII no autorizada.

## 4. Post-export
- Validar recepción (ack) del destinatario y hash.
- Guardar evidencias (logs, hashes, recibos) en repositorio WORM.
- Cerrar la solicitud y adjuntar artefactos en el expediente.

## 5. Controles y límites
- Rate limit y límites de filas por lote.
- Abort automático ante desviaciones (>x% respecto a estimado).

## 6. Referencias
- requirements.md: REQ-SEC-006..009, REQ-REG-005
- design.md: Controles de exportación, auditoría

