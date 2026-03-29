# Spike Decisions: Landing B2G Template Integration

**Change ID:** landing-b2g-gobierno
**Linear:** ALT-54 | **Date:** 2026-03-28

---

## 1. Template Selection

**Decision:** Use Bigspring Light Astro (themefisher/bigspring-light-astro) as base template.

**Rationale:** The template provides a production-ready Astro 6 + Tailwind CSS v4 + React 19 setup with MDX content support, sitemap generation, and a Bootstrap-style grid system via custom Tailwind plugin. This avoids bootstrapping from scratch while providing all the building blocks for a landing page.

**Modifications applied:**
- Renamed package to `@altrupets/landing-b2g`
- Updated `config.json` with AltruPets B2G branding (title, URL, meta)
- Replaced template colors with AltruPets design tokens in `theme.json`
- Added Cloudflare Workers deployment target (`wrangler.jsonc`)

---

## 2. Tailwind CSS v4 (CSS-based config, no tailwind.config.js)

**Decision:** Use Tailwind CSS v4 with the `@tailwindcss/vite` plugin and CSS-based configuration via `@plugin` directives, not a `tailwind.config.js` file.

**Rationale:** Astro 6 ships with native Tailwind v4 support. The template already uses this approach via `src/styles/main.css` with `@plugin` directives importing custom plugins from `src/tailwind-plugin/`. This is the forward-looking approach for Tailwind.

**Key files:**
- `src/styles/main.css` -- Entry point, imports Tailwind + plugins + component styles
- `src/tailwind-plugin/tw-theme.mjs` -- Design token colors, fonts, palette utility classes
- `src/tailwind-plugin/tw-bs-grid.mjs` -- Bootstrap-compatible grid system (`.row`, `.col-*`, `.g-*`)

---

## 3. Design Token Integration

**Decision:** All color palettes from `style-dictionary/tokens.json` are injected as CSS custom properties via the `tw-theme.mjs` plugin, enabling utility classes like `bg-primary-50`, `text-accent-80`, `border-neutral-90`, etc.

**Palettes included:**
- primary (13 shades: 0-100)
- secondary (13 shades)
- accent (13 shades)
- warning (13 shades)
- error (13 shades)
- success (13 shades)
- neutral (13 shades)
- neutral-variant (13 shades)

**Brand colors** (from `theme.json`): The template's original color system (`--color-primary`, `--color-secondary`, etc.) is preserved and mapped to AltruPets brand values. This means both `bg-primary` (brand #094F72) and `bg-primary-50` (palette #007FB6) work, matching the template's existing component expectations.

---

## 4. Font Strategy

**Decision:** Use Astro 6 built-in `fonts` API for all three font families.

| Font | Provider | Rationale |
|---|---|---|
| Lemon Milk | `fontProviders.local()` | Custom commercial font, not on Google Fonts. Source files from `style-dictionary/fonts/lemon_milk/` copied to `src/assets/fonts/lemon-milk/`. |
| Poppins | `fontProviders.local()` | Self-hosted for privacy/GDPR and zero external requests. Source files from `style-dictionary/fonts/poppins/` copied to `src/assets/fonts/poppins/`. |
| Inter | `fontProviders.google()` | No local files in `style-dictionary/fonts/`. Using Google Fonts provider. If self-hosting is required later, download from Google Fonts and switch to `local()`. |

**CSS variables:**
- `--font-primary` = Poppins (body text)
- `--font-header` = Lemon Milk (headings, mantras)
- `--font-tertiary` = Inter (labels, footer)

**Note:** The `tw-theme.mjs` plugin also generates `--font-primary`, `--font-header`, `--font-tertiary` from `theme.json`, enabling utility classes `font-primary`, `font-header`, `font-tertiary`.

---

## 5. Node.js Requirement

**Decision:** Require Node.js >= 22.12.0 (set in `.nvmrc` as `22`).

**Rationale:** Astro 6.x requires Node.js >= 22.12.0. The monorepo default is Node 20, but the landing-b2g project has its own `.nvmrc` file. Developers must run `nvm use` before working on this project, or use a tool like `fnm` with auto-switching.

**Impact:** CI/CD pipeline for this app must use Node 22. Other monorepo apps remain on Node 20.

---

## 6. Build and Deploy

**Decision:** Static site generation (SSG) with Cloudflare Workers as deployment target.

- `npm run build` generates static HTML/CSS/JS in `dist/`
- `npm run deploy:cf-workers` builds + deploys via Wrangler
- Build time: ~9.5 seconds for 15 pages
- Dev server: `npm run dev` on port 4321

**Not using:** Netlify (despite `netlify.toml` being present from template -- kept as fallback option).

---

## 7. What the Template Provides (kept as-is)

- MDX content pipeline with collection schemas
- Blog with pagination
- FAQ page with accordion components
- Contact page with form
- Pricing page with cards
- Shortcode components (Button, Accordion, Notice, Video, Tabs)
- Sitemap generation via `@astrojs/sitemap`
- React 19 integration for interactive components

---

## 8. What Needs to Change for B2G Landing (next phase)

These are out of scope for the spike but documented for the next Linear issues:

1. **New layout:** Replace multi-page nav with minimal Landing layout (logo + CTA only)
2. **New sections:** 12 landing sections per design.md (UrgencyBar, Hero, MantraBanner, etc.)
3. **Remove template content:** Blog posts, pricing page, generic FAQ -- replace with B2G-specific content
4. **Tracking:** GA4, Facebook Pixel, Google Ads conversion tags
5. **Scheduling:** Calendly/Cal.com embed for "Agendar demo en vivo" CTA
6. **Images:** Hero comparison image, partner logos, OG image
7. **Legal pages:** Spanish-language Terminos and Privacidad pages
