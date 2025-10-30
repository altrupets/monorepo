# Runbook: Break-Glass (Acceso Excepcional)

Propósito: Procedimiento para solicitar, aprobar, ejecutar y cerrar un acceso excepcional y auditado.

## 1. Pre-requisitos
- Caso/Incident ID creado y vinculado.
- Motivo legítimo documentado (auditoría, legal, incidente crítico).
- Tipo de datos identificado (Plataforma, PII central, Financiero/PCI, Gubernamental, Ambiental).

## 2. Solicitud
- Completar plantilla de aprobación (ver `templates/approval-break-glass.md`).
- Definir alcance exacto (datasets/tenants/columnas) y TTL.

## 3. Aprobación
- Doble control según tipo de datos (ver design.md, matriz de aprobadores).
- Verificar menor privilegio y TTL ≤ políticas.

## 4. Ejecución
- Emisión de credenciales temporales con scopes mínimos.
- Acceso solo lectura/enmascarado; sin PAN; límites de volumen.
- Monitoreo de anomalías; abortar ante picos o scraping.

## 5. Cierre
- Revocar credenciales (auto o manual si antes del TTL).
- Generar informe de auditoría con evidencias y hashes.
- Programar revisión post-mortem si procede.

## 6. Referencias
- requirements.md: REQ-SEC-006..009, REQ-REG-005, REQ-MT-010
- design.md: Anexo Flujo Break-Glass
