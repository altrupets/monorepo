# Pre-commit Hooks con Husky

Este directorio contiene la configuración de pre-commit hooks para el backend de AltruPets.

## Instalación

```bash
cd apps/backend
npm install
npm install -D husky lint-staged
chmod +x scripts/setup-husky.sh
./scripts/setup-husky.sh
```

## Hooks configurados

### pre-commit

Ejecuta las siguientes validaciones antes de cada commit:

1. **ESLint** - Verifica código TypeScript
2. **Prettier** - Formatea el código
3. **Secret scanning** - Detecta secrets accidentalmente commitidos

## Configuración de lint-staged

El archivo `lint-staged.config.js` en la raíz del proyecto configura qué archivos validar.

## Usage

Los hooks se ejecutan automáticamente en cada `git commit`. Para evitar esto:

```bash
git commit --no-verify  # Skip hooks
```

## Desinstalar

```bash
rm -rf .husky
npm pkg delete prepare
```
