# Sprint 8 (v1.0.0): Release Producción

> **Tipo:** `Chore`
> **Tamaño:** `M`
> **Estrategia:** `Human`
> **Componentes:** `Security`, `Infra`, `Testing`
> **Impacto:** `🔥 Critical Path`
> **Banderas:** `—`
> **Rama:** `release/v1.0.0`
> **Fuente de Spec:** `specs/altrupets/tasks.md` (sección Sprint 8)
> **Estado:** `No Iniciado`
> **Dependencias:** `Sprint 7 (CI/CD, Pruebas, Monitoreo)`
> **Proyecto Linear:** `Infrastructure & DevOps`

---

## 👤 CAPA HUMANA

### Historia de Usuario

Como **product owner**, quiero **pruebas de seguridad, endurecimiento de producción y un release limpio** para que **AltruPets v1.0.0 se lance con confianza para los primeros clientes municipales**.

### Contexto / Por Qué

El Sprint 8 es el empuje final antes del lanzamiento a producción. Las pruebas de seguridad (35) validan la encriptación, realizan pruebas de penetración básicas y verifican el cumplimiento SUGEF (AltruPets nunca toca los fondos). La seguridad de producción (38) agrega certificate pinning, ofuscación de código, detección de root/jailbreak y protección DDoS.

Este sprint requiere decisiones HUMANAS — qué umbrales de seguridad aplicar, qué nivel de ofuscación, si bloquear dispositivos rooteados por completo o solo advertir.

### Auditoría del Estado Actual

| Tarea | Estado | Evidencia |
|------|--------|----------|
| 35 (Pruebas de Seguridad) | PARCIAL | CodeQL, OWASP ZAP, TruffleHog configurados en CI/CD; sin pruebas de penetración ni verificación de flujo de fondos |
| 38 (Seguridad de Producción) | PARCIAL | Headers de Helmet, rate limiting, CORS configurados; sin cert pinning, ofuscación, detección de root |

### Criterios de Aceptación

- [ ] 35: Pruebas de validación de encriptación pasan para todos los flujos de datos sensibles
- [ ] 35: Reporte de pruebas de penetración básicas generado
- [ ] 35: Verificación de flujo de fondos: demostrar que AltruPets nunca toca fondos en ninguna ruta de código
- [ ] 38: Certificate pinning configurado para endpoints de API de producción
- [ ] 38: Ofuscación de código habilitada para builds de release
- [ ] 38: Detección de root/jailbreak con respuesta configurable (advertir vs bloquear)
- [ ] 38: Rate limiting ajustado para tráfico de producción (línea base DDoS)

### Estrategia del Agente

**Modo:** `Human`

**Decisiones necesarias:**
1. Certificate pinning: ¿qué CAs fijar? ¿Auto-gestionado o CDN (Cloudflare)?
2. Root/jailbreak: ¿bloquear completamente o solo advertir?
3. Nivel de ofuscación: ¿reglas R8/ProGuard para Android, bitcode para iOS?
4. Umbrales de rate limiting para producción (actual: 100 req/60s)

**Opciones a presentar:**
- Cert pinning: Fijar a CA raíz de Let's Encrypt (más simple) vs. fijar a intermediario específico (más seguro pero requiere gestión de rotación)
- Detección de root: Bloquear (más seguro, menos usuarios) vs. advertir (más usuarios, menos seguro)

**Trabajo preparatorio del agente:**
- Auditar todos los flujos de datos para intermediación de fondos
- Ejecutar escaneos de seguridad existentes y compilar reporte
- Preparar código de cert pinning para ambas opciones
- Configurar ofuscación en build.gradle y Xcode

---

## 🔀 Recomendación de Paralelización

**Mecanismo recomendado:** `Ninguno (Solo)` con puertas de decisión Human

**Razonamiento:** Las pruebas de seguridad son secuenciales por naturaleza. Cada hallazgo puede requerir una decisión antes de continuar. La participación humana como puerta de control evita que el agente tome decisiones de seguridad de forma autónoma.

**Estimación de costo:** ~1x costo base de tokens

---

## Recomendaciones de Issues en Linear

### Issue 1: Suite de Pruebas de Seguridad
**Título:** Ejecutar pruebas de penetración, validar encriptación, verificar aislamiento de flujo de fondos
**Proyecto:** Infrastructure & DevOps
**Prioridad:** Urgent
**Etiquetas:** Chore, M, Human, Security, Testing, 🔥 Critical Path

### Issue 2: Endurecimiento de Seguridad de Producción
**Título:** Configurar cert pinning, ofuscación de código, detección de root, protección DDoS
**Proyecto:** Infrastructure & DevOps + Mobile App
**Prioridad:** Urgent
**Etiquetas:** Chore, M, Human, Security, Infra, Frontend, 🔥 Critical Path

---

## Resumen de Archivos Afectados

| Acción | Ruta | Líneas Cambiadas (est.) |
|--------|------|---------------------|
| Crear | `apps/mobile/lib/core/security/` (3 archivos) | ~200 |
| Modificar | `apps/mobile/android/app/build.gradle` | ~30 |
| Modificar | `apps/backend/src/main.ts` | ~20 |
| Crear | Suite de pruebas de seguridad (5 archivos) | ~500 |
| Crear | `docs/security-audit-report.md` | ~200 |
