# 🧪 Testing

## Flutter Tests

```bash
# Unit tests
cd apps/mobile
flutter test

# Integration tests
flutter test integration_test/

# Coverage
flutter test --coverage
genhtml coverage/lcov.info -o coverage/html
```

## Backend Tests

```bash
cd apps/backend
npm test

# Watch mode
npm run test:watch
```

## E2E Tests

```bash
# Cypress (si aplica)
npm run e2e
```
