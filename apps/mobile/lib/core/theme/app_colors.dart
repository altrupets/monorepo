import 'package:flutter/material.dart';

/// Colores del Design System de AltruPets
/// Basado en Material 3 con paleta personalizada para protección animal
class AppColors {
  // Brand Colors
  static const Color primary = Color(0xFF094F72); // Brand Primary
  static const Color secondary = Color(0xFFEA840B); // Brand Secondary
  static const Color accent = Color(0xFF1370A6); // Brand Accent
  static const Color warning = Color(0xFFF4AE22); // Brand Warning
  static const Color error = Color(0xFFE54C12); // Brand Error
  static const Color errorContainer = Color(0xFFFFDAD6);
  static const Color onError = Color(0xFFFFFFFF);
  static const Color onErrorContainer = Color(0xFF410002);

  // Primary Containers
  static const Color primaryContainer = Color(0xFFD4E4ED);
  static const Color onPrimary = Color(0xFFFFFFFF);
  static const Color onPrimaryContainer = Color(0xFF031D2B);

  // Secondary Containers
  static const Color secondaryContainer = Color(0xFFFFEBD6);
  static const Color onSecondary = Color(0xFFFFFFFF);
  static const Color onSecondaryContainer = Color(0xFF4C2A02);

  // Success Colors (Mantener o ajustar según sea necesario)
  static const Color success = Color(0xFF2E7D32);
  static const Color successContainer = Color(0xFFC8E6C9);
  static const Color onSuccess = Color(0xFFFFFFFF);
  static const Color onSuccessContainer = Color(0xFF1B5E20);

  // Surface Colors (Ajustado a un tono oscuro profundo como se ve en la imagen)
  static const Color background = Color(0xFF0F172A); // Dark blueish background
  static const Color onBackground = Color(0xFFF8FAFC);
  static const Color surface = Color(0xFF1E293B);
  static const Color onSurface = Color(0xFFF8FAFC);

  static const Color surfaceContainerHighest = Color(0xFF334155);
  static const Color surfaceContainer = Color(0xFF1E293B);
  static const Color outline = Color(0xFF64748B);
  static const Color outlineVariant = Color(0xFF475569);

  // Tertiary Colors (Usando accent como base)
  static const Color tertiary = Color(0xFF1370A6);
  static const Color tertiaryContainer = Color(0xFFD1E5F0);
  static const Color onTertiary = Color(0xFFFFFFFF);
  static const Color onTertiaryContainer = Color(0xFF0D1E26);

  // Inverse Colors
  static const Color inverseSurface = Color(0xFFF8FAFC);
  static const Color inverseOnSurface = Color(0xFF0F172A);
  static const Color inversePrimary = Color(0xFF10B981);

  // Shadow & Scrim
  static const Color shadow = Color(0xFF000000);
  static const Color scrim = Color(0xFF000000);
}

/// Colores para Dark Theme (En este caso usaremos una paleta similar pero ajustada)
class AppColorsDark {
  static const Color primary = Color(0xFF1370A6);
  static const Color primaryContainer = Color(0xFF094F72);
  static const Color onPrimary = Color(0xFFFFFFFF);
  static const Color onPrimaryContainer = Color(0xFFD4E4ED);

  static const Color secondary = Color(0xFFEA840B);
  static const Color secondaryContainer = Color(0xFF4C2A02);
  static const Color onSecondary = Color(0xFFFFFFFF);
  static const Color onSecondaryContainer = Color(0xFFFFEBD6);

  static const Color error = Color(0xFFE54C12);
  static const Color errorContainer = Color(0xFF4C1906);
  static const Color onError = Color(0xFFFFFFFF);
  static const Color onErrorContainer = Color(0xFFFFDAD6);

  static const Color background = Color(0xFF0A0F1D);
  static const Color onBackground = Color(0xFFF1F5F9);
  static const Color surface = Color(0xFF111827);
  static const Color onSurface = Color(0xFFF1F5F9);

  static const Color surfaceContainerHighest = Color(0xFF1F2937);
  static const Color surfaceContainer = Color(0xFF111827);
  static const Color outline = Color(0xFF94A3B8);
  static const Color outlineVariant = Color(0xFF4B5563);

  // Tertiary Colors
  static const Color tertiary = Color(0xFF38BDF8);
  static const Color tertiaryContainer = Color(0xFF0C4A6E);
  static const Color onTertiary = Color(0xFF082F49);
  static const Color onTertiaryContainer = Color(0xFFBAE6FD);

  // Inverse Colors
  static const Color inverseSurface = Color(0xFFF1F5F9);
  static const Color inverseOnSurface = Color(0xFF0A0F1D);
  static const Color inversePrimary = Color(0xFF094F72);

  static const Color shadow = Color(0xFF000000);
  static const Color scrim = Color(0xFF000000);
}
