# Runbook: Manejo de Anomalías durante Break-Glass

Propósito: Detectar, responder y cerrar anomalías de uso durante sesiones break-glass.

## 1. Señales de anomalía
- Picos de volumen/velocidad vs presupuesto de sesión.
- Consultas fuera del alcance aprobado (tablas/tenants/columnas).
- Patrones de scraping/descarga masiva o automatización no declarada.

## 2. Respuesta inmediata
- Bloquear sesión (rescisión automática si supera umbrales).
- Notificar a Seguridad/Compliance y aprobadores.
- Preservar evidencias (snapshots de logs, hashes).

## 3. Contención y análisis
- Revisar motivos/aprobación y comparar con acciones ejecutadas.
- Ajustar límites/TTL si procede; acotar alcance.
- Registrar decisiones y responsables.

## 4. Cierre y post-mortem
- Generar informe de incidente con línea de tiempo y evidencias.
- Ejecutar post-mortem (ver plantilla `templates/postmortem.md`).
- Proponer mejoras (alertas, límites, vistas enmascaradas, capacitación).

## 5. Referencias
- requirements.md: REQ-SEC-009
- design.md: Controles de anomalías y auditoría

