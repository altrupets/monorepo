# Runbooks SRE de AltruPets

Este directorio contiene procedimientos operativos estandarizados (runbooks) para SREs y auditores.

## Índice

- break-glass: Acceso excepcional y auditado
  - Ver `break-glass.md`
- exportación controlada de datos
  - Ver `exportacion-controlada.md`
- anomalías durante break-glass
  - Ver `anomalias-break-glass.md`
- Plantillas
  - Aprobación doble: `templates/approval-break-glass.md`
  - Post-mortem: `templates/postmortem.md`

## Convenciones

- Siempre usar principio de menor privilegio, TTL y alcance mínimo.
- Todas las acciones deben quedar auditadas según `requirements.md` (REQ-SEC-008/009).
- Exportaciones con marca de agua y límites de volumen.
