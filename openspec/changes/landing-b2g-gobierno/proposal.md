# Propuesta: Landing Page B2G Municipal

**Change ID:** landing-b2g-gobierno
**SRD Task:** T0-7 (parcial), J7
**Linear:** ALT-53
**Sprint:** N/A (Marketing y Ventas)
**Fecha:** 2026-03-28

---

## Que

Construir el landing page de conversion para municipalidades costarricenses en `gobierno.altrupets.app`, posicionando AltruPets como la plataforma de gestion de bienestar animal que les permite cumplir con la Ley 7451 sin depender de SENASA.

## Por que

- **El 75% del revenue de AltruPets** proviene de contratos municipales (Persona P01 Gabriela).
- **No existe ninguna pagina publica** de marketing o conversion. Las unicas web apps son el portal B2G (login) y un CRUD de superusuarios.
- **Meta de negocio:** 15 ventas en el primer mes. Requiere 50-75 demos agendadas.
- **Pain point real de Marcela** (funcionaria municipal): pierde la mayor parte de su tiempo redireccionando "denuncias" ciudadanas al OIJ y la Fiscalia, porque los ciudadanos no entienden que el municipio solo puede actuar en captura de animales despues de una denuncia formal.
- **Contexto legal critico:**
  - Ley 7451 obliga a los municipios a proteger animales domesticos.
  - SENASA solo tiene competencia sobre animales de uso agropecuario. No tiene injerencia legal en animales domesticos/de compania.
  - Los municipios estan solos en esta responsabilidad.
- **Evidencia del problema:** La Municipalidad de Heredia tiene como "gestion de animales extraviados" una pagina con una imagen estatica de un perro y un numero de telefono. Screenshots en `docs/playbooks/`.

## Alcance

### Incluido

1. **Landing page completa** (12 secciones) con estructura What/Why/How (triangulo invertido)
2. **Secuencia emocional:** Miedo (incumplimiento legal) → Verguenza (deficiencia institucional) → Aspiracion (ser referente)
3. **CTAs:** Demo en vivo (principal), video pregrabado (soporte), propuesta formal (terciario)
4. **Integracion de tracking:** GA4, Facebook Pixel, Google Ads tag, Hotjar/Smartlook
5. **Formulario de agenda:** Integracion con Calendly o Cal.com
6. **SEO y OG tags**
7. **Responsive mobile-first**

### Excluido

- Landing B2B para clinicas veterinarias (`empresas.altrupets.app` — futuro)
- Landing B2C para rescatistas/adoptantes
- Tabla de precios publica
- Blog
- Integraciones con CRM
- Video pregrabado (produccion audiovisual, fuera de scope tecnico)

## Etiquetas

| Etiqueta | Valor |
|----------|-------|
| Journey | J7 (Panel Municipal), J5 (Reportes de Maltrato) |
| Prioridad SRD | Revenue-Critical |
| Tamano | M (dias) |
| Dependencias | Ninguna (independiente del backend) |

## Analogia

Es como crear el escaparate de una tienda: el producto (plataforma AltruPets) ya existe adentro, pero sin vitrina nadie sabe que existe. El landing es la vitrina que atrae a Gabriela a entrar y pedir una demostracion.

## Riesgos y Mitigaciones

| Riesgo | Mitigacion |
|--------|-----------|
| Sin social proof fuerte (no hay clientes activos) | Usar alianzas existentes + numeros de impacto del sector (82 cantones, 0 plataformas) |
| Copy legal sobre Ley 7451 podria ser impreciso | Verificar redaccion con el texto legal antes de publicar |
| Video pregrabado no existe aun | El landing funciona sin video; el CTA principal es demo en vivo |
| Bigspring Light puede necesitar customizacion pesada | El template es MIT y Tailwind, facil de adaptar sin fork |
