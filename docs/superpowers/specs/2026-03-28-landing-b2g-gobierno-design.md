# Landing Page B2G - gobierno.altrupets.app

**Issue:** [ALT-53](https://linear.app/altrupets/issue/ALT-53/modelar-pagina-de-embudo-funnellanding)
**Fecha:** 2026-03-28
**Estado:** Aprobado por el usuario

---

## 1. Objetivo

Disenar e implementar un landing page de conversion para municipalidades costarricenses, posicionando AltruPets como la plataforma de gestion de bienestar animal que les permite cumplir con la Ley 7451 sin depender de SENASA.

**Meta de negocio:** 15 ventas en el primer mes.
**Metrica proxy:** 50-75 demos en vivo agendadas (asumiendo 20-30% de conversion).

## 2. Audiencia

**Persona principal:** Marcela -- funcionaria municipal encargada de bienestar animal.

**Pain point central:** Marcela no es responsable de procesar denuncias de maltrato animal. Su competencia legal es intervenir en la captura de animales unicamente despues de que alguien haya interpuesto una denuncia ante el OIJ o la Fiscalia. Sin embargo, los ciudadanos no entienden este flujo y le envian "denuncias" directamente. Marcela pierde la mayor parte de su tiempo redireccionando personas a los entes correctos.

**Contexto legal critico:**
- La Ley 7451 de Bienestar Animal obliga a los municipios a garantizar la proteccion de animales domesticos en su jurisdiccion.
- SENASA unicamente tiene competencia sobre animales de uso agropecuario. No tiene injerencia legal en casos de animales domesticos o de compania.
- Los municipios estan solos en esta responsabilidad, aunque muchos creen que SENASA los respalda.

## 3. Embudo de conversion

Estructura de dos pasos siguiendo el metodo del triangulo invertido (What / Why / How):

```
Video pregrabado (calentador opcional)
         |
         v
   Demo en vivo (CTA principal, cierre de venta)
         |
         v
Propuesta formal (para proceso de licitacion)
```

- **CTA principal:** "Agendar demo en vivo" -- permite leer microexpresiones, calificar leads, y cerrar.
- **CTA secundario:** "Ver video explicativo (3 min)" -- para informarse sin compromiso y compartir internamente.
- **CTA terciario:** "Solicitar propuesta formal" -- genera documento para licitacion.

## 4. Secuencia emocional

El landing recorre tres emociones en orden:

1. **Miedo** (incumplimiento legal) -- Barra de urgencia + Hero
2. **Verguenza** (deficiencia institucional) -- Seccion de problemas actuales
3. **Aspiracion** (ser referente) -- Proceso + CTA final

## 5. Stack tecnico

| Componente | Tecnologia |
|---|---|
| Framework | Astro (template Bigspring Light) |
| Styling | Tailwind CSS + design tokens de `style-dictionary/` |
| Hosting | Subdominio `gobierno.altrupets.app` |
| Tracking | Google Analytics + pixeles Facebook/Google Ads |
| Heatmaps | Hotjar o Smartlook |
| Formulario | Integracion con calendario (Calendly o Cal.com) |
| Contenido | Markdown/MDX |

**Colores de brand (de `style-dictionary/tokens.json`):**

| Token | Hex | Uso en el landing |
|---|---|---|
| `brand-primary` | `#094F72` | Headers, fondos principales |
| `brand-secondary` | `#EA840B` | Botones CTA (complementario, resalta) |
| `brand-accent` | `#1370A6` | Links, CTAs secundarios |
| `brand-error` | `#E54C12` | Barra de urgencia |
| `brand-success` | `#2E7D32` | Checkmarks, confirmaciones |
| `error-30` | `#842500` | Fondo barra de urgencia |
| `primary-10` | `#001E2F` | Fondos oscuros (hero, video, CTA final) |
| `primary-20` | `#00344E` | Franjas de transicion oscuras |
| `primary-95` | `#E6F2FF` | Fondos claros de seccion |
| `secondary-90` | `#FFDCC2` | Franjas de transicion calidas |
| `neutral-95` | `#F0F0F3` | Fondos de prueba social |

**Tipografia (de `style-dictionary/tokens.json`):**

| Fuente | Uso |
|---|---|
| Lemon Milk | Titulos principales (hero, CTAs finales) |
| Poppins | Cuerpo de texto, subtitulos |
| Inter | Texto terciario, labels, footer |

## 6. Estructura de secciones (12 secciones)

### Seccion 1: Barra superior persistente (Urgencia regulatoria)

- **Fondo:** `error-30` (`#842500`), texto blanco
- **Comportamiento:** Fija al hacer scroll
- **Copy:**

> **Ley 7451 de Bienestar Animal** -- Los municipios tienen la obligacion de garantizar proteger a los animales domesticos en su jurisdiccion. Legalmente SENASA no esta obligada a hacerlo. **Enterese como su municipalidad puede lograrlo.**

- El link hace scroll al CTA principal.

### Seccion 2: Hero / Above the Fold (WHAT -- Miedo)

- **Fondo:** `primary-10` (`#001E2F`), texto blanco
- **Layout:** Dos columnas. Izquierda: copy. Derecha: screenshot comparativo (pagina actual de municipio vs dashboard AltruPets).

**Titulo (Lemon Milk, bold):**
> "Deje de ser la operadora telefonica de denuncias que no le corresponden."

**Subtitulo (Poppins, regular):**
> "El 80% de los reportes que recibe su oficina de bienestar animal deberian ir al OIJ o la Fiscalia, no a usted. AltruPets filtra y redirige automaticamente, para que usted solo vea los casos donde su municipio SI puede actuar."

**CTA principal** (boton `secondary` `#EA840B`, texto blanco):
> "Agendar demo en vivo"

**CTA secundario** (link texto `accent` `#1370A6`):
> "Ver video explicativo (3 min)"

**Linea de confianza** (texto pequeno):
> "Ya en proceso con municipios costarricenses"

### Seccion 3: Franja de transicion (Mantra 1)

- **Fondo:** `secondary-90` (`#FFDCC2`)
- **Copy centrado (Poppins, semibold, `primary` `#094F72`):**

> "Si no puede medir cuantos animales rescato su canton este mes, no puede justificar el presupuesto del proximo."

### Seccion 4: THE WHY -- Tres problemas, tres soluciones (Verguenza institucional)

- **Fondo:** Blanco (`#FFFFFF`)

**Titulo:**
> "Esto es lo que pasa hoy en su municipio"

**Tres columnas:**

| Problema | Solucion AltruPets |
|---|---|
| **Ciudadanos lo llaman a USTED para denunciar maltrato.** Su oficina se convierte en call center redirigiendo gente al OIJ y la Fiscalia. | AltruPets guia al ciudadano al ente correcto desde el primer contacto. A usted solo le llegan los casos accionables. |
| **Los rescatistas coordinan por WhatsApp.** Sin trazabilidad, sin evidencia, sin reportes para el concejo. | Panel en tiempo real con cada caso documentado: fotos, ubicacion GPS, estado, responsable asignado. |
| **Su pagina de "animales extraviados" es una imagen estatica.** Cero busqueda, cero reportes, cero datos. | Feed actualizado, busqueda por zona, y reportes automaticos para rendicion de cuentas. |

### Seccion 5: "Para quien es?" con botones de salto

- **Fondo:** `primary-95` (`#E6F2FF`)

**Titulo:**
> "AltruPets es para su municipio si..."

**Tres cards con checkmarks (`success` `#2E7D32`):**

1. "Recibe reportes de maltrato animal que no sabe como tramitar"
2. "Necesita datos reales para justificar presupuesto ante el concejo"
3. "Quiere cumplir con la Ley 7451 sin depender de SENASA"

**Cada card tiene boton de salto** (`secondary` `#EA840B`):
> "Ver como funciona" (scroll a seccion 7)

### Seccion 6: Franja de transicion (Mantra 2)

- **Fondo:** `primary-20` (`#00344E`), texto blanco

**Copy centrado:**
> "Los datos no mienten. Pero para tener datos, primero necesita un sistema."

### Seccion 7: THE HOW -- Proceso de implementacion (Aspiracion)

- **Fondo:** Blanco (`#FFFFFF`)

**Titulo:**
> "Funcionando en su municipio en 3 pasos"

**Tres pasos horizontales con iconos numerados en `primary` `#094F72`:**

| Paso | Titulo | Descripcion |
|---|---|---|
| **01** | Agenda una demo | Le mostramos el panel con datos reales de su canton. 30 minutos, sin compromiso. |
| **02** | Configuramos su municipio | Adaptamos zonas, rescatistas, y flujos de denuncia a su jurisdiccion. 1 semana de setup. |
| **03** | Su equipo opera con datos | Casos trazables, reportes automaticos para el concejo, y ciudadanos bien dirigidos desde el dia uno. |

### Seccion 8: Prueba social

- **Fondo:** `neutral-95` (`#F0F0F3`)

**Titulo:**
> "Municipios que ya estan en proceso"

- Logos de alianzas en fila, escala de grises con hover a color.
- Debajo: "En fase de implementacion"
- Si hay cita de funcionario aliado, usarla como testimonial.

**Alternativa si no hay citas (numeros de impacto):**

| Dato | Contexto |
|---|---|
| **82 cantones** | en Costa Rica sin herramienta digital de bienestar animal |
| **Ley 7451** | obliga a los municipios, no a SENASA |
| **0 plataformas** | especializadas en coordinacion municipal de rescate animal en LATAM |

### Seccion 9: Video pregrabado

- **Fondo:** `primary-10` (`#001E2F`), texto blanco

**Titulo:**
> "Vea el panel en accion (3 minutos)"

- Video embebido centrado, thumbnail del dashboard.
- No mostrar contador de reproducciones.
- Dos CTAs debajo:
  - Primario (`secondary` `#EA840B`): "Agendar demo en vivo"
  - Secundario (borde `accent` `#1370A6`, fondo transparente): "Solicitar propuesta formal"

### Seccion 10: FAQ

- **Fondo:** Blanco (`#FFFFFF`)

**Titulo:**
> "Preguntas frecuentes"

**Acordeones desplegables:**

1. **"AltruPets reemplaza a SENASA?"**
   No. SENASA unicamente tiene competencia sobre animales de uso agropecuario -- legalmente no tiene injerencia en casos de animales domesticos o de compania. Esa responsabilidad recae directamente en su municipio bajo la Ley 7451. AltruPets es la herramienta que le permite cumplir con esa obligacion.

2. **"Cuanto cuesta?"**
   Cada municipio tiene necesidades distintas. Agendemos una demo para entender su canton y prepararle una propuesta personalizada.

3. **"Cuanto dura la implementacion?"**
   Una semana de configuracion. Su equipo puede operar desde el dia uno con capacitacion incluida.

4. **"Necesitamos licitar?"**
   Le proporcionamos toda la documentacion necesaria para su proceso de contratacion administrativa.

5. **"Que pasa con las denuncias que no nos corresponden?"**
   AltruPets guia automaticamente al ciudadano hacia el OIJ o la Fiscalia cuando el caso lo requiere. A su oficina solo le llegan los casos donde el municipio tiene competencia legal.

6. **"Y si ya tenemos un sistema interno?"**
   AltruPets se integra con sus procesos existentes. No reemplaza, complementa y digitaliza.

### Seccion 11: CTA final + garantia

- **Fondo:** `primary-20` (`#00344E`), texto blanco

**Titulo (Lemon Milk):**
> "Su canton merece mas que una imagen estatica y un numero de telefono."

**Subtitulo:**
> "Agendemos 30 minutos. Si no ve valor en la demo, no le pedimos nada mas."

**CTA grande centrado** (`secondary` `#EA840B`):
> "Agendar demo en vivo"

**Debajo, texto pequeno en `neutral-70`:**
> "Sin costo. Sin compromiso. 30 minutos."

### Seccion 12: Footer

- **Fondo:** `neutral-10` (`#191C1E`)
- Logo AltruPets (isotipo de `style-dictionary/isotipo.svg`)
- Links: Terminos, Privacidad, Contacto
- Redes sociales
- `gobierno.altrupets.app` | `info@altrupets.app`

## 7. Directrices de diseno y usabilidad

1. **Botones CTA:** Siempre en `secondary` `#EA840B`. Nunca del mismo color que los titulos (`primary`).
2. **Tipografia:** Prohibido color gris para parrafos largos. Usar `neutral-10` (`#191C1E`) sobre fondo claro.
3. **Botones de salto:** En seccion 5 ("Para quien es?"), cada card salta directamente a la seccion 7 (proceso).
4. **Repeticion del mensaje clave:** El CTA "Agendar demo en vivo" aparece en secciones 2, 9, y 11 (minimo 3 veces).
5. **Navegacion minima:** Sin menu de navegacion complejo. Solo logo + CTA en el header.
6. **Responsive:** Mobile-first. Las columnas de seccion 4 pasan a stack vertical en mobile.
7. **Colores de fondo alternados:** Cada seccion usa un fondo distinto para evitar monotonia visual (ver paleta por seccion arriba).

## 8. Requerimientos tecnicos y de medicion

1. **Google Analytics 4** -- Eventos personalizados: `cta_click` (con label: demo/video/propuesta), `scroll_depth`, `faq_expand`.
2. **Pixeles de retargeting** -- Facebook Pixel + Google Ads tag para remarketing a funcionarios que visitaron pero no agendaron.
3. **Heatmaps** -- Hotjar o Smartlook para observar comportamiento real de los funcionarios en la pagina.
4. **UTM tracking** -- Parametros UTM en todas las URLs de campana para atribucion.
5. **PageSpeed** -- Mantener 95+ en Google PageSpeed (Bigspring Light lo soporta nativamente).
6. **OG tags** -- Open Graph y Twitter Cards con imagen del dashboard para cuando se comparte el link.

## 9. Evidencia de referencia

Screenshots capturados de la Municipalidad de Heredia como ejemplo del estado actual:
- `docs/playbooks/heredia-bienestar-animal.png` -- Pagina de bienestar animal (texto estatico + telefonos SENASA)
- `docs/playbooks/heredia-animales-extraviados.png` -- Pagina de animales extraviados (una imagen estatica de un perro)

Estos pueden usarse como material de contraste en el hero (seccion 2) y en presentaciones de venta.

## 10. Fuera de alcance

- Landing B2B para clinicas veterinarias (futuro: `empresas.altrupets.app`)
- Landing B2C para rescatistas/adoptantes
- Tabla de precios publica (se entrega en propuesta formal)
- Blog (fase posterior)
- Integraciones con CRM (fase posterior)
