# ADR-001: Landing Page B2G para Municipalidades

**Fecha:** 2026-03-28
**Estado:** Aceptado
**Issue:** [ALT-53](https://linear.app/altrupets/issue/ALT-53/modelar-pagina-de-embudo-funnellanding)

## Contexto

AltruPets necesita una pagina de conversion para vender su plataforma a municipalidades costarricenses. No existe ninguna pagina publica de marketing. La meta es 15 ventas en el primer mes. El 75% del revenue proviene de contratos municipales.

## Decisiones

### 1. Audiencia: Solo municipalidades

**Opciones consideradas:**
- A) Solo municipalidades (Persona Marcela)
- B) Solo clinicas veterinarias (Persona Dr. Carlos)
- C) Ambos en un solo landing

**Decision:** Opcion A.

**Razon:** Las municipalidades representan el 75% del revenue. El ciclo de venta B2G es completamente diferente al B2B de clinicas. Un landing enfocado convierte mejor que uno generico. Se construira un landing B2B separado en `empresas.altrupets.app` posteriormente.

### 2. CTA principal: Demo en vivo (no video pregrabado)

**Opciones consideradas:**
- A) Agendar demo en vivo
- B) Video pregrabado como paso obligatorio previo
- C) Demo interactiva (sandbox autoguiado)

**Decision:** Opcion A como CTA principal, video pregrabado como soporte opcional.

**Razon:**
- La demo en vivo permite leer microexpresiones faciales del funcionario para detectar objeciones no verbalizadas.
- Con meta de 15 ventas/mes y conversion de 20-30%, se necesitan 50-75 demos. El video como paso obligatorio frenaria el pipeline.
- El video pregrabado sirve para que Marcela lo comparta internamente (su jefe, legal, presupuesto) sin depender de nuestro calendario.

### 3. Secuencia emocional: Miedo → Verguenza → Aspiracion

**Opciones consideradas:**
- A) Contraste antes/despues (verguenza primero)
- B) Vision positiva (aspiracion primero)
- C) Presion normativa (miedo primero)

**Decision:** C → A → B en secuencia. Miedo primero, verguenza segundo, aspiracion tercero.

**Razon:** En B2G, el miedo al incumplimiento legal captura atencion inmediata. La verguenza profundiza el dolor al mostrar la realidad (paginas municipales estaticas). La aspiracion ofrece la salida y motiva la accion.

### 4. Pricing: Oculto, solo en propuesta formal

**Opciones consideradas:**
- A) Mostrar rangos de precio
- B) Ocultar, entregar en propuesta formal
- C) Tabla de planes tipo SaaS

**Decision:** Opcion B.

**Razon:** Cada municipio tiene presupuestos y procesos de licitacion distintos. Mostrar precio sin contexto puede asustar. La tabla de planes (opcion C) se reserva para el futuro landing B2B en `empresas.altrupets.app`.

### 5. Urgencia: Regulacion real, no contadores artificiales

**Opciones consideradas:**
- A) Ciclo presupuestario municipal
- B) Cupo limitado de onboarding
- C) Regulacion entrante (Ley 7451)
- D) Sin urgencia artificial

**Decision:** Opcion C.

**Razon:** La Ley 7451 obliga a los municipios a proteger animales domesticos. SENASA unicamente tiene competencia sobre animales de uso agropecuario, no domesticos/de compania. Esta es una presion legal real y verificable, no un contador artificial que destruiria confianza con funcionarios publicos.

### 6. Dominio: Subdominio gobierno.altrupets.app

**Opciones consideradas:**
- A) `altrupets.app` (raiz)
- B) `gobierno.altrupets.app` (subdominio)
- C) `altrupets.app/gobierno` (ruta)

**Decision:** Opcion B.

**Razon:** Separacion clara entre landing B2G, futuro landing B2B (`empresas.altrupets.app`), y producto. Permite analytics y SEO independientes por audiencia.

### 7. Stack: Astro (Bigspring Light) + Tailwind CSS

**Opciones consideradas:**
- A) Vue 3 + Vite (consistente con apps/web/)
- B) HTML/CSS/JS estatico
- C) Astro con template Bigspring Light

**Decision:** Opcion C.

**Razon:** Astro es SSG optimizado para landing pages (95+ PageSpeed nativo). Bigspring Light viene con secciones prearmadas (hero, servicios, proceso, FAQ, pricing), contenido en Markdown/MDX, Tailwind CSS, y licencia MIT. No requiere framework SPA para una pagina estatica de conversion.

## Descubrimientos clave

### Pain point real de Marcela

La funcionaria municipal de bienestar animal **no es responsable de procesar denuncias de maltrato**. Su competencia legal es intervenir en la captura de animales unicamente despues de que alguien haya interpuesto una denuncia ante el OIJ o la Fiscalia. Los ciudadanos no entienden este flujo y le envian "denuncias" directamente. Marcela pierde la mayor parte de su tiempo redireccionando personas a los entes correctos.

**Implicacion para el producto:** AltruPets no es "un dashboard de denuncias" sino un filtro inteligente que triaja automaticamente: guia al ciudadano al ente correcto y solo muestra a Marcela los casos donde el municipio tiene competencia legal.

### SENASA no cubre animales domesticos

SENASA unicamente tiene competencia sobre animales de uso agropecuario. No tiene injerencia legal en casos de animales domesticos o de compania. Los municipios creen que SENASA los respalda, pero legalmente estan solos en esta responsabilidad bajo la Ley 7451.

### Evidencia del estado actual municipal

La Municipalidad de Heredia tiene como "gestion de animales extraviados" una pagina con una imagen estatica de un perro y un numero de telefono. Screenshots capturados en `docs/playbooks/heredia-bienestar-animal.png` y `docs/playbooks/heredia-animales-extraviados.png`.

## Consecuencias

- Se necesita producir un video pregrabado de 3 minutos mostrando el dashboard (fuera de scope tecnico).
- Se necesitan logos de alianzas municipales existentes para la seccion de prueba social.
- Contenido legal (Terminos, Privacidad) necesita revision antes de publicar.
- El copy sobre Ley 7451 debe verificarse con el texto legal exacto.
- Futuros landings (B2B, B2C) seguiran un proceso similar pero con audiencia, dolor, y CTA distintos.
