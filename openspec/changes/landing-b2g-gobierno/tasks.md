# Tareas: Landing Page B2G Municipal

**Change ID:** landing-b2g-gobierno
**SRD Task:** T0-7 (parcial) | **Linear:** ALT-53 | **Sprint:** Marketing

---

## Spike: Evaluacion y Setup del Template

- [x] **SP-01** Clonar Bigspring Light Astro template en `apps/web/landing-b2g/`
- [x] **SP-02** Verificar compatibilidad de Astro 6.x con Tailwind CSS y Node.js del monorepo
- [x] **SP-03** Configurar Tailwind con design tokens de `style-dictionary/tokens.json` (colores, fuentes)
- [x] **SP-04** Copiar fuentes (Lemon Milk, Poppins, Inter) de `style-dictionary/fonts/` a `public/fonts/`
- [x] **SP-05** Verificar que `npm run dev` levanta correctamente en puerto local
- [x] **SP-06** Documentar decisiones de integracion del template con el monorepo

## Layout y Componentes Base

- [ ] **LC-01** Crear layout `Landing.astro` sin nav compleja (solo logo + CTA en header)
- [ ] **LC-02** Crear componente `CTAButton.astro` con variantes: primary (`#EA840B`), secondary (borde `#1370A6`), ghost
- [ ] **LC-03** Crear componente `SectionTitle.astro` con fuente Lemon Milk
- [ ] **LC-04** Crear componente `MantraBanner.astro` reutilizable (recibe texto, fondo, color)

## Secciones del Landing

### Bloque 1: THE WHAT (Miedo)

- [ ] **S-01** Implementar `UrgencyBar.astro` — barra fija `error-30` con copy de Ley 7451, link scroll al CTA
- [ ] **S-02** Implementar `Hero.astro` — dos columnas, titulo Lemon Milk, subtitulo Poppins, CTA principal + secundario, linea de confianza, fondo `primary-10`

### Bloque 2: THE WHY (Verguenza)

- [ ] **S-03** Implementar mantra 1 — `MantraBanner.astro` con fondo `secondary-90`, texto `primary`
- [ ] **S-04** Implementar `Problems.astro` — titulo + 3 columnas problema/solucion, fondo blanco, responsive stack en mobile
- [ ] **S-05** Implementar `ForWho.astro` — 3 cards con checkmarks `success`, botones de salto a seccion 7, fondo `primary-95`
- [ ] **S-06** Implementar mantra 2 — `MantraBanner.astro` con fondo `primary-20`, texto blanco

### Bloque 3: THE HOW (Aspiracion)

- [ ] **S-07** Implementar `Process.astro` — 3 pasos horizontales numerados con iconos, fondo blanco
- [ ] **S-08** Implementar `SocialProof.astro` — logos en escala de grises con hover a color, numeros de impacto como fallback, fondo `neutral-95`
- [ ] **S-09** Implementar `VideoSection.astro` — embed de video con thumbnail, 2 CTAs debajo, fondo `primary-10`. Placeholder hasta que exista el video.
- [ ] **S-10** Implementar `FAQ.astro` — acordeones desplegables con 6 preguntas, contenido desde `faq.json`, fondo blanco
- [ ] **S-11** Implementar `FinalCTA.astro` — titulo Lemon Milk, subtitulo, CTA grande centrado, texto de garantia, fondo `primary-20`
- [ ] **S-12** Implementar `Footer.astro` — isotipo, links legales, redes sociales, fondo `neutral-10`

## Contenido

- [ ] **C-01** Crear `faq.json` con las 6 preguntas y respuestas completas
- [ ] **C-02** Crear pagina `terminos.astro` con contenido legal placeholder
- [ ] **C-03** Crear pagina `privacidad.astro` con contenido legal placeholder
- [ ] **C-04** Preparar imagen `hero-comparison.png` (screenshot Heredia vs dashboard mockup)
- [ ] **C-05** Preparar `og-image.png` para Open Graph

## Integraciones

- [ ] **I-01** Configurar Calendly/Cal.com embed para CTA "Agendar demo en vivo"
- [ ] **I-02** Integrar Google Analytics 4 con eventos custom: `cta_click`, `scroll_depth`, `faq_expand`
- [ ] **I-03** Integrar Facebook Pixel con eventos `Lead` y `ViewContent`
- [ ] **I-04** Integrar Google Ads conversion tag
- [ ] **I-05** Integrar Hotjar o Smartlook para heatmaps

## SEO y Performance

- [ ] **P-01** Configurar meta tags y OG tags en layout
- [ ] **P-02** Verificar Google PageSpeed 95+ (mobile y desktop)
- [ ] **P-03** Optimizar imagenes (WebP, lazy loading)
- [ ] **P-04** Configurar sitemap.xml y robots.txt

## Deployment

- [ ] **D-01** Configurar DNS para `gobierno.altrupets.app` (subdominio en altrupets.app)
- [ ] **D-02** Configurar deploy (Vercel, Netlify, o hosting actual)
- [ ] **D-03** Configurar SSL/TLS para el subdominio
- [ ] **D-04** Smoke test en produccion: todas las secciones, CTAs, responsive, tracking
