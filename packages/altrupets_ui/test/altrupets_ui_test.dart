import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:altrupets_ui/altrupets_ui.dart';

void main() {
  test('AltruPetsTheme.light returns a ThemeData', () {
    final theme = AltruPetsTheme.light;
    expect(theme, isA<ThemeData>());
    expect(theme.useMaterial3, isTrue);
  });

  test('AltruPetsTheme.dark returns a ThemeData', () {
    final theme = AltruPetsTheme.dark;
    expect(theme, isA<ThemeData>());
    expect(theme.useMaterial3, isTrue);
    expect(theme.brightness, Brightness.dark);
  });
}
