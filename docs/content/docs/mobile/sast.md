# Flutter SAST (Static Analysis)

El script `flutter-sast.sh` proporciona análisis estático de código para Flutter.

## Uso

```bash
./flutter-sast.sh [command]
```

### Comandos disponibles

| Comando | Descripción |
|---------|-------------|
| `analyze` | Ejecuta `dart analyze` (default) |
| `test` | Ejecuta unit tests |
| `coverage` | Ejecuta tests con coverage |
| `lint` | Ejecuta análisis + formato |
| `all` | Ejecuta análisis completo |

## Ejemplos

### Análisis básico

```bash
./flutter-sast.sh analyze
```

### Tests con coverage

```bash
./flutter-sast.sh coverage
```

Output: `coverage/lcov.info`

### Análisis completo

```bash
./flutter-sast.sh all
```

## Integración con Makefile

```bash
make dev-mobile-analyze      # dart analyze
make dev-mobile-test         # unit tests
make dev-mobile-test-coverage # tests con coverage
make dev-mobile-lint         # all linting
```

## CI/CD

Para integrar en pipelines:

```yaml
# GitHub Actions example
- name: Flutter SAST
  run: |
    cd apps/mobile
    ./flutter-sast.sh all
```

## Herramientas incluidas

- **dart analyze**: Análisis estático de Dart
- **flutter test**: Unit tests
- **flutter format**: Verificación de formato

## Configuración

El análisis usa las reglas definidas en:
- `analysis_options.yaml` - Reglas de linting
- `dart_test.yaml` - Configuración de tests
