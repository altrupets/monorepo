# Security Vulnerabilities - Breaking Changes Required

**Fecha:** 2026-02-18
**Proyecto:** AltruPets Monorepo
**Fuente:** npm audit report

---

## Resumen Ejecutivo

Existen **101 vulnerabilidades** en las dependencias de Node.js que requieren **breaking changes** para solucionarse. La mayoría vienen de dependencias transitivas y requieren actualización de paquetes principales.

---

## Vulnerabilidades Críticas (Critical)

### 1. babel-traverse

| Campo | Detalle |
|-------|---------|
| **Severidad** | Critical |
| **CVE** | GHSA-67hx-6x53-jw92 |
| **Descripción** | Babel vulnerable to arbitrary code execution when compiling specifically crafted malicious code |
| **Paquete** | `babel-traverse` |
| **Fix** | `npm audit fix --force` |
| **Impacto** | Instalará `jest@30.2.0` |

**Dependencias afectadas:**
```
babel-traverse
└── babel-core
    ├── babel-jest (old version)
    │   └── jest-runtime (old version)
    │       └── jest-haste-map (old version)
    │           └── jest-resolve (old version)
    └── babel-register
```

**Solución sugerida:** Actualizar a versiones modernas de jest/babel-jest.

---

### 2. form-data

| Campo | Detalle |
|-------|---------|
| **Severidad** | Critical |
| **CVE** | GHSA-fjxv-7rqg-78g4 |
| **Descripción** | form-data uses unsafe random function in form-data for choosing boundary |
| **Paquete** | `form-data` |
| **Fix** | `npm audit fix --force` |
| **Impacto** | Instalará `jest@30.2.0` |

**Dependencias afectadas:**
```
form-data
└── request
    ├── jsdom
    │   └── jest-environment-jsdom
    │       └── jest-config
    │           └── jest
    └── request-promise-native
```

**Solución sugerida:** Eliminar uso de `request` y migrar a `axios` o `node-fetch`.

---

### 3. lodash (múltiples CVE)

| Campo | Detalle |
|-------|---------|
| **Severidad** | Critical |
| **CVE** | GHSA-fvqr-27wr-82fm, GHSA-35jh-r3h4-6jhm, GHSA-4xc9-xhrj-v574, GHSA-jf85-cpcp-j695, GHSA-p6mc-m468-83gw |
| **Descripción** | Prototype Pollution y Command Injection en lodash |
| **Paquete** | `lodash` <=4.17.20 |
| **Fix** | `npm audit fix --force` |
| **Impacto** | Instalará `@nestjs/cli@11.0.16` |

**Dependencias afectadas:**
```
lodash
└── cli-table2
    └── caporal (old)
        └── @nestjs/cli (old)
```

**Solución sugerida:**
- Actualizar `@nestjs/cli` a versión reciente
- O usar `lodash` como dependencia directa en versión >=4.17.21

---

## Vulnerabilidades de Alta Severidad (High)

### 4. @apollo/server

| Campo | Detalle |
|-------|---------|
| **Severidad** | High |
| **CVE** | GHSA-mp6q-xf9x-fwf7 |
| **Descripción** | Apollo Server vulnerable to Denial of Service with `startStandaloneServer` |
| **Versión vulnerable** | 5.0.0 - 5.3.0 |
| **Fix** | `npm audit fix` |
| **Solución** | Actualizar a >=5.3.1 |

---

### 5. body-parser

| Campo | Detalle |
|-------|---------|
| **Severidad** | High |
| **CVE** | GHSA-qwcr-r2fm-qrc7 |
| **Descripción** | body-parser vulnerable to denial of service when url encoding is enabled |
| **Fix** | `npm audit fix` |
| **Rama** | `nestjs-inertia/node_modules/body-parser` |

**Dependencias afectadas:**
```
body-parser
└── express
```

**Solución sugerida:** Actualizar `nestjs-inertia` o evaluar alternativa.

---

### 6. braces

| Campo | Detalle |
|-------|---------|
| **Severidad** | High |
| **CVE** | GHSA-grv7-fg5c-xmjg |
| **Descripción** | Uncontrolled resource consumption in braces |
| **Fix** | `npm audit fix --force` |
| **Impacto** | Instalará `@nestjs/cli@11.0.16` |

---

### 7. minimatch

| Campo | Detalle |
|-------|---------|
| **Severidad** | High |
| **CVE** | GHSA-3ppc-4f35-3m26 |
| **Descripción** | minimatch has a ReDoS via repeated wildcards with non-matching literal in pattern |
| **Fix** | `npm audit fix --force` |
| **Impacto** | Instalará `jest@30.2.0`, `eslint@10.0.0` |

**Dependencias afectadas:**
```
minimatch
├── glob
│   ├── rimraf
│   │   └── flat-cache
│   │       └── test-exclude
│   │           └── babel-plugin-istanbul
│   └── typeorm (old)
│       └── @nestjs/typeorm
│           └── @nestjs/terminus
└── @typescript-eslint/typescript-estree
    └── typescript-eslint
```

---

### 8. multer

| Campo | Detalle |
|-------|---------|
| **Severidad** | High |
| **CVE** | GHSA-4pg4-qvpc-4q3h, GHSA-g5hg-p3ph-g8qg, GHSA-fjgf-rc76-4x9p |
| **Descripción** | Multer vulnerable to Denial of Service |
| **Fix** | `npm audit fix` |
| **Rama** | `nestjs-inertia/node_modules/multer` |

---

### 9. path-to-regexp

| Campo | Detalle |
|-------|---------|
| **Severidad** | High |
| **CVE** | GHSA-9wv6-86v2-598j, GHSA-rhx6-c78j-4q9w |
| **Descripción** | path-to-regexp outputs backtracking regular expressions (ReDoS) |
| **Fix** | `npm audit fix` |
| **Rama** | `nestjs-inertia` |

---

### 10. qs

| Campo | Detalle |
|-------|---------|
| **Severidad** | High |
| **CVE** | GHSA-6rw7-vpxm-498p, GHSA-w7fw-mjwx-w883 |
| **Descripción** | qs allows DoS via arrayLimit bypass |
| **Fix** | `npm audit fix --force` |
| **Impacto** | Instalará `jest@30.2.0` |

---

### 11. send

| Campo | Detalle |
|-------|---------|
| **Severidad** | High |
| **CVE** | GHSA-m6fv-jmcg-4jfg |
| **Descripción** | send vulnerable to template injection leading to XSS |
| **Fix** | `npm audit fix` |
| **Rama** | `nestjs-inertia` |

---

### 12. cross-spawn

| Campo | Detalle |
|-------|---------|
| **Severidad** | High |
| **CVE** | GHSA-3xgq-45jj-v275 |
| **Descripción** | Regular Expression Denial of Service (ReDoS) in cross-spawn |
| **Fix** | `npm audit fix --force` |
| **Impacto** | Instalará `@nestjs/cli@11.0.16` |

---

### 13. got

| Campo | Detalle |
|-------|---------|
| **Severidad** | Moderate |
| **CVE** | GHSA-pfrx-2q88-qq97 |
| **Descripción** | Got allows a redirect to a UNIX socket |
| **Fix** | `npm audit fix --force` |
| **Impacto** | Instalará `@nestjs/cli@11.0.16` |

---

### 14. json5

| Campo | Detalle |
|-------|---------|
| **Severidad** | High |
| **CVE** | GHSA-9c47-m6qq-7p4h |
| **Descripción** | Prototype Pollution in JSON5 via Parse Method |
| **Fix** | `npm audit fix --force` |
| **Impacto** | Instalará `jest@30.2.0` |

---

### 15. merge

| Campo | Detalle |
|-------|---------|
| **Severidad** | High |
| **CVE** | GHSA-7wpw-2hjm-89gp |
| **Descripción** | Prototype Pollution in merge |
| **Fix** | `npm audit fix --force` |
| **Impacto** | Instalará `jest@30.2.0` |

---

### 16. tmp

| Campo | Detalle |
|-------|---------|
| **Severidad** | High |
| **CVE** | GHSA-52f5-9888-hmc6 |
| **Descripción** | tmp allows arbitrary temporary file/directory write via symbolic link |
| **Fix** | `npm audit fix --force` |
| **Impacto** | Instalará `eslint@10.0.0` |

---

### 17. trim-newlines

| Campo | Detalle |
|-------|---------|
| **Severidad** | High |
| **CVE** | GHSA-7p7h-4mm5-852v |
| **Descripción** | Uncontrolled Resource Consumption in trim-newlines |
| **Fix** | `npm audit fix` |

---

## Vulnerabilidades Moderadas (Moderate)

### 18. ajv

| Campo | Detalle |
|-------|---------|
| **Severidad** | Moderate |
| **CVE** | GHSA-2g4f-4pwh-qvx6 |
| **Descripción** | ajv has ReDoS when using `$data` option |
| **Fix** | `npm audit fix --force` |
| **Impacto** | Instalará `eslint@4.0.0` |

---

### 19. @nestjs/common

| Campo | Detalle |
|-------|---------|
| **Severidad** | Moderate |
| **CVE** | GHSA-cj7v-w2c7-cp7c |
| **Descripción** | nest allows a remote attacker to execute arbitrary code via the Content-Type header |
| **Fix** | No fix available |
| **Rama** | `nestjs-inertia` |

**Nota:** Actualizar `nestjs-inertia` a versión que use `@nestjs/common>=10.4.16`

---

### 20. cookie

| Campo | Detalle |
|-------|---------|
| **Severidad** | Moderate |
| **CVE** | GHSA-pxg6-pf52-xh8x |
| **Descripción** | cookie accepts cookie name, path, and domain with out of bounds characters |
| **Fix** | `npm audit fix` |

---

### 21. node-notifier

| Campo | Detalle |
|-------|---------|
| **Severidad** | Moderate |
| **CVE** | GHSA-5fw9-fq32-wv5p |
| **Descripción** | OS Command Injection in node-notifier |
| **Fix** | `npm audit fix --force` |
| **Impacto** | Instalará `jest@30.2.0` |

---

### 22. tough-cookie

| Campo | Detalle |
|-------|---------|
| **Severidad** | Moderate |
| **CVE** | GHSA-72xf-g2v4-qvf3 |
| **Descripción** | tough-cookie Prototype Pollution vulnerability |
| **Fix** | `npm audit fix --force` |
| **Impacto** | Instalará `jest@30.2.0` |

---

### 23. yargs-parser

| Campo | Detalle |
|-------|---------|
| **Severidad** | Moderate |
| **CVE** | GHSA-p9pc-299p-vxgp |
| **Descripción** | yargs-parser Vulnerable to Prototype Pollution |
| **Fix** | `npm audit fix --force` |
| **Impacto** | Instalará `jest@30.2.0` |

---

## Recomendaciones de Fix

### Opción 1: Actualización Completa (Recomendada)

```bash
# Forzar actualización de todas las dependencias
npm audit fix --force

# Luego regenerar lockfile
rm -rf node_modules package-lock.json
npm install
```

**Pros:** Resuelve todas las vulnerabilidades
**Cons:** Requiere testing exhaustivo por breaking changes

### Opción 2: Actualización Selectiva

```bash
# Actualizar solo paquetes principales
npm install @nestjs/cli@latest jest@latest typescript-eslint@latest

# Luego aplicar fix
npm audit fix
```

### Opción 3: Actualizar nestjs-inertia

El paquete `nestjs-inertia` es la fuente principal de vulnerabilidades. Opciones:

1. Actualizar `nestjs-inertia` a última versión
2. Migrar a alternativa (si no hay update disponible)
3. Eliminar si no es necesario

---

## Plan de Acción Sugerido

1. **Inmediato:** Revisar uso de `nestjs-inertia` - actualizar o eliminar
2. **Corto plazo:** Actualizar `@nestjs/cli` y relacionados
3. **Mediano plazo:** Migrar de `request` a `axios`
4. **Largo plazo:** Actualizar jest y related tools completamente

---

## Notas

- Las vulnerabilidades en `nestjs-inertia/node_modules/` vienen de dependencias anidadas
- El paquete `nestjs-inertia` puede estar obsoleto o sin mantenimiento
- Considerar evaluación de alternativas modernas
