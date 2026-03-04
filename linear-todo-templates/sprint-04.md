# Sprint 4 (v0.6.0): Ecosistema Vet + Donaciones

> **Tipo:** `Feature`
> **Tamaño:** `L`
> **Estrategia:** `Team`
> **Componentes:** `Backend`, `Database`, `Frontend`
> **Impacto:** `💰 Revenue`
> **Banderas:** `📦 Epic`, `🚫 Blocked`
> **Branch:** `feat/sprint-4-vet-donations`
> **Fuente de Spec:** `specs/altrupets/tasks.md` (sección Sprint 4)
> **Estado:** `Blocked`
> **Dependencias:** `Sprint 2 (flujo de trabajo de subsidios) + Sprint 1 (Casa Cuna)`
> **Proyecto Linear:** `Backend` + `Mobile App`

---

## ⚠️ BLOQUEADORES

| Bloqueador | Requerido Para | Sprint |
|---------|-------------|--------|
| T0-4/T0-5 Flujo de trabajo de subsidios | V1 (facturación se vincula a subsidios aprobados) | Sprint 2 |
| T0-8 Perfil Veterinario | Tareas 19-20 (gestión de pacientes vet necesita entidad vet) | Sprint 1 |
| T0-2 Casa Cuna | Tarea 23 (lista de necesidades para donaciones) | Sprint 1 |
| T1-4 Chat (Firestore) | Tarea 25 (integración de chat con flujos de trabajo) | Existe parcialmente |

---

## 👤 CAPA HUMANA

### Historia de Usuario

Como **veterinario (P03 Dr. Carlos)**, quiero **gestionar pacientes, enviar facturas por tratamientos subsidiados y rastrear la contribución de mi clínica** para que **pueda participar eficientemente en el programa de subsidios municipal y hacer crecer mi práctica**.

Como **donante (P10 Roberto)**, quiero **ver qué necesitan las organizaciones de rescate y donar directamente (dinero o insumos) sin que AltruPets toque los fondos** para que **pueda apoyar el bienestar animal de forma transparente**.

### Contexto / Por Qué

El Sprint 4 completa el ecosistema veterinario de principio a fin (desde la aprobación del subsidio en el Sprint 2 → tratamiento veterinario → factura → seguimiento de pago) y habilita el sistema de donaciones que mantiene financiadas a las organizaciones de rescate. También integra el chat existente con los flujos de trabajo operativos, reduciendo el cambio de contexto.

El flujo de facturación veterinaria (V1) cierra el ciclo de la funcionalidad de ingresos #1 (subsidios). Sin facturación, las municipalidades no pueden verificar que los fondos autorizados se usaron correctamente — rompiendo la cadena de rendición de cuentas que justifica los contratos B2G.

Las donaciones P2P están estructuradas para cumplir con SUGEF (Ley 7786) — AltruPets NUNCA toca los fondos. Los donantes envían dinero directamente a las cuentas bancarias de las organizaciones (SINPE/IBAN) o coordinan entregas de insumos.

### Analogía

El Sprint 4 es como conectar el departamento de facturación al hospital. El Sprint 2 construyó la aprobación del seguro (subsidios). Ahora el doctor (veterinario) necesita registrar lo que hizo, enviar una factura y recibir el pago. Mientras tanto, la comunidad (donantes) puede ver qué necesita el hospital y traer insumos directamente.

### Errores Conocidos y Advertencias

1. **Cumplimiento SUGEF (Ley 7786):** AltruPets NUNCA debe intermediar fondos. El flujo de donación muestra los datos bancarios de la organización (SINPE, IBAN) y el donante confirma que envió el dinero de forma externa. AltruPets solo registra la declaración.
2. **Auto-creación de salas de chat:** Las salas de chat de Firebase Firestore necesitan crearse programáticamente desde el backend NestJS. Esto requiere el Firebase Admin SDK en el lado del servidor.
3. **Trazabilidad de facturas:** Cada subsidio debe tener una cadena completa: solicitud → aprobación → tratamiento → factura → pago. Los eslabones faltantes rompen la confianza de la municipalidad.
4. **Donaciones en especie:** Alimentos, medicinas e insumos son de primera clase junto con las donaciones monetarias (Regla SRD #10). La UX debe tratarlos de forma igualitaria.
5. **Donaciones recurrentes:** La funcionalidad de "recordatorio mensual" requiere un scheduler (ya agregado en el Sprint 2 para la expiración de subsidios).

---

## 🤖 CAPA AGENTE

### Objetivo

Construir gestión de pacientes veterinarios (solicitudes de atención, registros médicos), facturación de subsidios veterinarios (factura digital → seguimiento municipal), sistema de donaciones entre pares (monetario + en especie, cumplimiento SUGEF), integración de chat con flujos de trabajo (auto-crear salas para casos de rescate/adopción), y reportes de transparencia (reportes configurables con exportación PDF/Excel).

### Auditoría del Estado Actual

#### Ya Existe

- `apps/mobile/lib/features/messages/` — Feature de chat (Firestore, independiente)
- `apps/backend/src/subsidies/` — ⚠️ Necesita existir del Sprint 2
- `apps/backend/src/vet-profiles/` — ⚠️ Necesita existir del Sprint 1
- `apps/mobile/lib/core/services/costa_rica_payment_gateways.dart` — Infraestructura de pasarela de pagos (existe, no conectada para donaciones)

#### Necesita Creación

- `apps/backend/src/medical-records/` — Módulo completo (entity, service, resolver)
- `apps/backend/src/invoices/` — Módulo completo
- `apps/backend/src/donations/` — Módulo completo
- `apps/backend/src/reports/` — Módulo de reportes de transparencia
- `apps/backend/src/migrations/XXXXXX-CreateMedicalRecordEntity.ts`
- `apps/backend/src/migrations/XXXXXX-CreateInvoiceEntity.ts`
- `apps/backend/src/migrations/XXXXXX-CreateDonationEntity.ts`
- `apps/mobile/lib/features/vet/` — Feature de gestión de pacientes veterinarios
- `apps/mobile/lib/features/donations/` — Feature de donaciones

#### Necesita Modificación

- `apps/mobile/lib/features/messages/` — Integrar con flujos de trabajo (auto-crear salas)
- `apps/backend/src/app.module.ts` — Registrar nuevos módulos

### Criterios de Aceptación

#### Gestión de Pacientes Veterinarios (Tareas 19-20)
- [ ] Buscar veterinarios por proximidad y especialidad
- [ ] Solicitar atención veterinaria urgente con flujo de aceptar/rechazar
- [ ] Registro médico: diagnóstico, tratamiento, medicamentos, fotos
- [ ] Historial médico por animal (vinculado a la entidad Animal)

#### Facturación Veterinaria (Tarea V1)
- [ ] Veterinario genera factura digital por tratamiento subsidiado
- [ ] Factura se vincula a SubsidyRequest aprobada
- [ ] Seguimiento de estado: SUBMITTED → RECEIVED → PAID
- [ ] Trazabilidad completa desde solicitud hasta pago

#### Donaciones P2P (Tarea 23)
- [ ] Donante ve lista de necesidades de Casa Cuna
- [ ] Donación monetaria: muestra SINPE/IBAN de la organización, donante confirma pago externo
- [ ] Donación en especie: coordinar entrega vía chat
- [ ] Opción de donación recurrente (recordatorio mensual)
- [ ] AltruPets NUNCA toca los fondos

#### Integración de Chat (Tarea 25)
- [ ] Auto-crear sala de chat cuando inicia un caso de rescate (centinela + auxiliar + rescatista)
- [ ] Auto-crear sala de chat cuando inicia un proceso de adopción (rescatista + adoptante)
- [ ] Chat vinculado a caso/solicitud
- [ ] Auto-archivar al completar el caso

#### Reportes de Transparencia (Tarea 22)
- [ ] Reportes configurables por rango de fechas
- [ ] Métricas de impacto: animales rescatados/adoptados/subsidiados, donaciones recibidas
- [ ] Exportación a PDF y Excel
- [ ] Disponible para municipalidades (dashboard) y organizaciones

### Restricciones Técnicas

- Cumplimiento SUGEF: SIN intermediación de fondos. Mostrar datos bancarios, solo registrar declaración.
- Firebase Admin SDK requerido en el backend para auto-creación de salas de chat
- La entidad Invoice hace referencia a SubsidyRequest (FK)
- Los registros médicos hacen referencia a la entidad Animal (FK)
- Las donaciones deben distinguir entre tipos monetario vs. en especie
- Generación de reportes: Usar pdfmake o similar para PDF, exceljs para Excel

### Estrategia del Agente

**Modo:** `Team`

**Compañeros de equipo:**
- Compañero 1: **Backend (Vet + Facturación + Donaciones)** → responsable de `apps/backend/src/medical-records/`, `apps/backend/src/invoices/`, `apps/backend/src/donations/`
- Compañero 2: **Móvil (Vet + Donaciones)** → responsable de `apps/mobile/lib/features/vet/`, `apps/mobile/lib/features/donations/`
- Compañero 3: **Integración de Chat + Reportes** → responsable de integración de chat con flujos de trabajo, `apps/backend/src/reports/`

**Modo de visualización:** `tab`
**Aprobación de plan requerida:** sí

---

## 🔀 Recomendación de Paralelización

**Mecanismo recomendado:** `Agent Teams`

**Razonamiento:** 5 fases independientes (H, I, J, K, L) con 3 carriles tecnológicos claros. La integración de chat (K) depende de la configuración del Firebase Admin SDK pero es independiente de la creación de entidades.

**Estimación de costo:** ~3x costo base de tokens

---

## Recomendaciones de Issues en Linear

### Issue 1: Gestión de Pacientes Veterinarios
**Título:** Construir solicitudes de atención veterinaria, registros médicos e historial de tratamientos
**Proyecto:** Backend + Mobile App
**Prioridad:** High
**Etiquetas:** Feature, M, Team, Backend, Frontend, 💰 Revenue

### Issue 2: Facturación de Subsidios Veterinarios
**Título:** Construir facturación digital de subsidios: enviar, rastrear, pagar
**Proyecto:** Backend
**Prioridad:** High
**Etiquetas:** Feature, M, Solo, Backend, 💰 Revenue

### Issue 3: Donaciones P2P
**Título:** Construir sistema de donaciones entre pares (SINPE + en especie, cumplimiento SUGEF)
**Proyecto:** Backend + Mobile App
**Prioridad:** High
**Etiquetas:** Feature, M, Team, Backend, Frontend

### Issue 4: Integración de Chat con Flujos de Trabajo
**Título:** Auto-crear salas de chat para flujos de trabajo de rescate/adopción
**Proyecto:** Backend + Mobile App
**Prioridad:** Medium
**Etiquetas:** Improvement, S, Solo, Backend, Frontend

### Issue 5: Reportes de Transparencia
**Título:** Construir reportes de transparencia configurables con exportación PDF/Excel
**Proyecto:** Backend + Web Quality
**Prioridad:** Medium
**Etiquetas:** Feature, M, Solo, Backend, Web Quality

---

## Resumen de Archivos Modificados

| Acción | Ruta | Líneas Cambiadas (est.) |
|--------|------|---------------------|
| Crear | `apps/backend/src/medical-records/` (4 archivos) | ~300 |
| Crear | `apps/backend/src/invoices/` (4 archivos) | ~250 |
| Crear | `apps/backend/src/donations/` (4 archivos) | ~300 |
| Crear | `apps/backend/src/reports/` (4 archivos) | ~250 |
| Crear | `apps/backend/src/migrations/` (3 archivos) | ~120 |
| Modificar | `apps/backend/src/app.module.ts` | ~15 |
| Crear | `apps/mobile/lib/features/vet/` (6 archivos) | ~500 |
| Crear | `apps/mobile/lib/features/donations/` (6 archivos) | ~400 |
| Modificar | `apps/mobile/lib/features/messages/` (3 archivos) | ~150 |
| Crear | Tests | ~400 |

---

### Comentarios Adicionales de Síntesis

#### Validación Lógica MECE

* **Mutuamente Excluyente:** Cada fase crea módulos de dominio separados. La facturación (I) depende de Subsidios (Sprint 2) pero no genera conflictos. La integración de chat (K) modifica el feature de mensajes existente pero no toca los archivos de ninguna otra fase.

* **Colectivamente Exhaustivo:** Cubre T1-4 (chat), T1-5 (gestión vet), T1-7 (facturación), T1-8 (donaciones), T1-9 (reportes) — todas las tareas del Sprint 4.

#### Síntesis Ejecutiva (Pirámide de Minto)

1. **Liderar con la Respuesta:** El Sprint 4 cierra el ciclo de ingresos veterinarios (subsidio → tratamiento → factura → pago) y abre el canal de donaciones — completando el motor económico de la plataforma.

2. **Argumentos de Soporte:**
   - **Ecosistema Veterinario (H+I):** Completa el recorrido del veterinario desde recibir solicitudes de subsidio hasta facturar a municipalidades
   - **Donaciones (J):** Habilita el financiamiento comunitario de organizaciones de rescate sin riesgo regulatorio
   - **Chat + Reportes (K+L):** Integra la comunicación con los flujos de trabajo y proporciona transparencia para la rendición de cuentas

#### Pareto 80/20

* El módulo de facturación (V1) cierra el ciclo de rendición de cuentas de subsidios — alto valor por 1 entidad + 2 endpoints.
* Las donaciones en especie (Tarea 23) agregan complejidad significativa de UX para una funcionalidad que puede tener menor volumen inicial que las donaciones monetarias. Considerar lanzar primero la parte monetaria y agregar en especie en el Sprint 5.

#### Pensamiento de Segundo Orden

* **Riesgo SUGEF:** El sistema de registro de donaciones debe diseñarse cuidadosamente para evitar CUALQUIER implicación de que AltruPets procesa pagos. Se recomienda revisión legal del texto de la UX.
* **Firebase Admin SDK:** Agregar el Firebase Admin SDK al backend NestJS introduce una nueva dependencia y requisito de gestión de credenciales. Almacenar el JSON de la cuenta de servicio en Infisical.
