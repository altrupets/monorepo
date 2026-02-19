# 🎨 Design System

Material 3 con tokens de diseño personalizados.

## Colores

```dart
AppColors.primary      // Brand primary
AppColors.secondary    // Brand secondary
AppColors.error        // Errores
AppColors.success      // Éxito
AppColors.surface      // Superficies
AppColors.outline      // Bordes
```

### Modo Oscuro

```dart
AppColorsDark.primary  // Primary invertido
AppColorsDark.surface  // Surface oscuro
```

## Tipografía

Fuentes: **Lemon Milk** (títulos), **Poppins** (cuerpo)

```dart
Theme.of(context).textTheme.headlineMedium
Theme.of(context).textTheme.bodyMedium
Theme.of(context).textTheme.labelLarge
```

## Theme Provider

```dart
final themeMode = ref.watch(themeModeProvider);

// Toggle
ref.read(themeModeProvider.notifier).toggleTheme();
```

## Spacing

```dart
AppSpacing.xs   // 4
AppSpacing.sm   // 8
AppSpacing.md   // 16
AppSpacing.lg   // 24
AppSpacing.xl   // 32
```

## Border Radius

```dart
AppRadius.sm    // 8
AppRadius.md    // 12
AppRadius.lg    // 16
AppRadius.full  // 9999
```

## Uso en App

```dart
MaterialApp(
  theme: AppTheme.lightTheme(),
  darkTheme: AppTheme.darkTheme(),
  themeMode: themeMode,
)
```

## Best Practices

```dart
// ✅ Correcto
color: AppColors.primary
style: Theme.of(context).textTheme.bodyMedium
padding: EdgeInsets.all(AppSpacing.md)

// ❌ Incorrecto
color: Color(0xFF6366F1)
style: TextStyle(fontSize: 14)
padding: EdgeInsets.all(17)
```
