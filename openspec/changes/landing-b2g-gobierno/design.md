# Diseno: Landing Page B2G Municipal

**Change ID:** landing-b2g-gobierno
**SRD Task:** T0-7 (parcial) | **Linear:** ALT-53 | **Sprint:** Marketing

---

## 1. Arquitectura Tecnica

### 1.1 Stack

| Componente | Tecnologia | Justificacion |
|---|---|---|
| Framework | Astro (Bigspring Light template) | SSG, 95+ PageSpeed, SEO nativo |
| Styling | Tailwind CSS | Consistente con template, customizable con design tokens |
| Design Tokens | `style-dictionary/tokens.json` | Colores y tipografia de brand |
| Hosting | `gobierno.altrupets.app` (subdominio) | Separacion clara B2G vs producto |
| Formulario | Calendly o Cal.com embed | Agendar demo sin backend propio |
| Tracking | GA4 + Facebook Pixel + Google Ads | Medicion de conversion y retargeting |
| Heatmaps | Hotjar o Smartlook | Comportamiento real de usuarios |
| Contenido | Markdown/MDX | Editable sin tocar codigo |

### 1.2 Estructura de Proyecto

```
apps/web/landing-b2g/
├── astro.config.mjs
├── tailwind.config.js
├── tsconfig.json
├── package.json
├── public/
│   ├── images/
│   │   ├── isotipo.svg          (desde style-dictionary/)
│   │   ├── hero-comparison.png  (screenshot antes/despues)
│   │   ├── partner-logos/       (logos de alianzas)
│   │   └── og-image.png         (Open Graph)
│   └── fonts/
│       ├── LemonMilk/
│       ├── Poppins/
│       └── Inter/
├── src/
│   ├── layouts/
│   │   └── Landing.astro        (layout base sin nav compleja)
│   ├── components/
│   │   ├── UrgencyBar.astro     (seccion 1)
│   │   ├── Hero.astro           (seccion 2)
│   │   ├── MantraBanner.astro   (secciones 3, 6)
│   │   ├── Problems.astro       (seccion 4)
│   │   ├── ForWho.astro         (seccion 5)
│   │   ├── Process.astro        (seccion 7)
│   │   ├── SocialProof.astro    (seccion 8)
│   │   ├── VideoSection.astro   (seccion 9)
│   │   ├── FAQ.astro            (seccion 10)
│   │   ├── FinalCTA.astro       (seccion 11)
│   │   ├── Footer.astro         (seccion 12)
│   │   └── ui/
│   │       ├── CTAButton.astro
│   │       ├── SectionTitle.astro
│   │       └── FAQAccordion.astro
│   ├── pages/
│   │   ├── index.astro          (landing principal)
│   │   ├── terminos.astro
│   │   └── privacidad.astro
│   ├── content/
│   │   └── faq.json             (preguntas frecuentes)
│   └── styles/
│       └── tokens.css           (importado de style-dictionary/)
└── .env.example
    ├── GA_MEASUREMENT_ID=
    ├── FB_PIXEL_ID=
    ├── GOOGLE_ADS_ID=
    └── CALENDLY_URL=
```

## 2. Paleta de Colores (de style-dictionary/tokens.json)

### Mapeo seccion → color de fondo

| Seccion | Fondo | Texto |
|---|---|---|
| 1. Barra urgencia | `error-30` `#842500` | Blanco |
| 2. Hero | `primary-10` `#001E2F` | Blanco |
| 3. Mantra 1 | `secondary-90` `#FFDCC2` | `primary` `#094F72` |
| 4. Problemas | `#FFFFFF` | `neutral-10` `#191C1E` |
| 5. Para quien | `primary-95` `#E6F2FF` | `neutral-10` `#191C1E` |
| 6. Mantra 2 | `primary-20` `#00344E` | Blanco |
| 7. Proceso | `#FFFFFF` | `neutral-10` `#191C1E` |
| 8. Social proof | `neutral-95` `#F0F0F3` | `neutral-10` `#191C1E` |
| 9. Video | `primary-10` `#001E2F` | Blanco |
| 10. FAQ | `#FFFFFF` | `neutral-10` `#191C1E` |
| 11. CTA final | `primary-20` `#00344E` | Blanco |
| 12. Footer | `neutral-10` `#191C1E` | `neutral-70` `#AAABAE` |

### Componentes UI

| Componente | Color |
|---|---|
| Boton CTA primario | `secondary` `#EA840B` fondo, blanco texto |
| Boton CTA secundario | Borde `accent` `#1370A6`, fondo transparente |
| Links | `accent` `#1370A6` |
| Checkmarks | `success` `#2E7D32` |
| Titulos (Lemon Milk) | Heredan color de seccion |
| Parrafos (Poppins) | Nunca gris, siempre `neutral-10` o blanco |

## 3. Tipografia

| Fuente | Uso | Weight |
|---|---|---|
| Lemon Milk | Titulos hero, CTA final, mantras | Bold |
| Poppins | Subtitulos, cuerpo de texto, FAQ | Regular, Semibold |
| Inter | Labels, footer, texto terciario | Regular |

## 4. Copy por Seccion

### Seccion 1: Barra superior persistente

> **Ley 7451 de Bienestar Animal** -- Los municipios tienen la obligacion de garantizar proteger a los animales domesticos en su jurisdiccion. Legalmente SENASA no esta obligada a hacerlo. **Enterese como su municipalidad puede lograrlo.**

### Seccion 2: Hero

**Titulo:** "Deje de ser la operadora telefonica de denuncias que no le corresponden."

**Subtitulo:** "El 80% de los reportes que recibe su oficina de bienestar animal deberian ir al OIJ o la Fiscalia, no a usted. AltruPets filtra y redirige automaticamente, para que usted solo vea los casos donde su municipio SI puede actuar."

**CTA principal:** "Agendar demo en vivo"
**CTA secundario:** "Ver video explicativo (3 min)"
**Confianza:** "Ya en proceso con municipios costarricenses"

### Seccion 3: Mantra 1

> "Si no puede medir cuantos animales rescato su canton este mes, no puede justificar el presupuesto del proximo."

### Seccion 4: Tres problemas / tres soluciones

**Titulo:** "Esto es lo que pasa hoy en su municipio"

1. **Ciudadanos lo llaman a USTED para denunciar maltrato.** → AltruPets guia al ciudadano al ente correcto desde el primer contacto.
2. **Los rescatistas coordinan por WhatsApp.** → Panel en tiempo real con cada caso documentado.
3. **Su pagina de "animales extraviados" es una imagen estatica.** → Feed actualizado, busqueda por zona, reportes automaticos.

### Seccion 5: Para quien es

**Titulo:** "AltruPets es para su municipio si..."

1. "Recibe reportes de maltrato animal que no sabe como tramitar"
2. "Necesita datos reales para justificar presupuesto ante el concejo"
3. "Quiere cumplir con la Ley 7451 sin depender de SENASA"

### Seccion 6: Mantra 2

> "Los datos no mienten. Pero para tener datos, primero necesita un sistema."

### Seccion 7: Proceso en 3 pasos

**Titulo:** "Funcionando en su municipio en 3 pasos"

1. **Agenda una demo** — 30 minutos, sin compromiso.
2. **Configuramos su municipio** — 1 semana de setup.
3. **Su equipo opera con datos** — Desde el dia uno.

### Seccion 8: Prueba social

**Titulo:** "Municipios que ya estan en proceso"

Alternativa con numeros: 82 cantones sin herramienta | Ley 7451 obliga municipios | 0 plataformas en LATAM

### Seccion 9: Video

**Titulo:** "Vea el panel en accion (3 minutos)"

### Seccion 10: FAQ

6 preguntas (ver proposal.md para copy completo de cada respuesta):
1. AltruPets reemplaza a SENASA?
2. Cuanto cuesta?
3. Cuanto dura la implementacion?
4. Necesitamos licitar?
5. Que pasa con las denuncias que no nos corresponden?
6. Y si ya tenemos un sistema interno?

### Seccion 11: CTA final

**Titulo:** "Su canton merece mas que una imagen estatica y un numero de telefono."
**Subtitulo:** "Agendemos 30 minutos. Si no ve valor en la demo, no le pedimos nada mas."
**CTA:** "Agendar demo en vivo"
**Bajo CTA:** "Sin costo. Sin compromiso. 30 minutos."

### Seccion 12: Footer

Logo + Terminos + Privacidad + Contacto + Redes + `gobierno.altrupets.app`

## 5. Directrices de UX

1. **Botones CTA:** Siempre `secondary` `#EA840B`. Nunca del mismo color que titulos.
2. **Tipografia:** Prohibido gris para parrafos largos. `neutral-10` sobre claro, blanco sobre oscuro.
3. **Botones de salto:** Seccion 5 salta a seccion 7 (proceso).
4. **Repeticion CTA:** "Agendar demo en vivo" aparece en secciones 2, 9, y 11 (minimo 3x).
5. **Navegacion minima:** Solo logo + CTA en header. Sin menu complejo.
6. **Responsive:** Mobile-first. Columnas de seccion 4 pasan a stack vertical.
7. **Fondos alternados:** Cada seccion con fondo distinto para romper monotonia.

## 6. Tracking y Medicion

### Eventos GA4

| Evento | Parametros | Trigger |
|---|---|---|
| `cta_click` | `label: demo\|video\|propuesta`, `section: N` | Click en cualquier CTA |
| `scroll_depth` | `percent: 25\|50\|75\|100` | Scroll milestones |
| `faq_expand` | `question: string` | Click en acordeon FAQ |
| `urgency_bar_click` | — | Click en barra superior |
| `video_play` | `duration: N` | Play del video pregrabado |

### Pixeles de retargeting

- Facebook Pixel: evento `Lead` al agendar demo, `ViewContent` al ver video
- Google Ads: conversion tag al completar formulario de agenda

### OG Tags

```html
<meta property="og:title" content="AltruPets — Gestion de Bienestar Animal para Municipios" />
<meta property="og:description" content="Cumpla con la Ley 7451 sin depender de SENASA. Panel de control para su canton." />
<meta property="og:image" content="https://gobierno.altrupets.app/images/og-image.png" />
<meta property="og:url" content="https://gobierno.altrupets.app" />
```

## 7. Acceptance Criteria

- [ ] Landing accesible en `gobierno.altrupets.app`
- [ ] 12 secciones renderizadas con colores de brand correctos
- [ ] CTA "Agendar demo en vivo" funcional (redirige a Calendly/Cal.com)
- [ ] Barra superior fija al scroll
- [ ] FAQ acordeones funcionales (expand/collapse)
- [ ] Responsive: funcional en mobile (375px+), tablet, desktop
- [ ] Google PageSpeed 95+ (mobile y desktop)
- [ ] GA4 configurado con eventos custom
- [ ] OG tags funcionando (verificar con opengraph.xyz)
- [ ] Paginas de Terminos y Privacidad accesibles
