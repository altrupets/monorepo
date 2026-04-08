import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:altrupets_ui/altrupets_ui.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  test('AltruPetsTokens has correct primary color', () {
    expect(AltruPetsTokens.primary, const Color(0xFF094F72));
  });

  test('AltruPetsTokens has correct surface colors', () {
    expect(AltruPetsTokens.surfaceBackground, const Color(0xFF080812));
    expect(AltruPetsTokens.surfaceCard, const Color(0xFF1A1A2E));
    expect(AltruPetsTokens.surfaceBorder, const Color(0xFF2A2A40));
  });

  test('AltruPetsTokens has correct status colors', () {
    expect(AltruPetsTokens.success, const Color(0xFF4CAF50));
    expect(AltruPetsTokens.warning, const Color(0xFFFF9800));
    expect(AltruPetsTokens.error, const Color(0xFFEF5350));
    expect(AltruPetsTokens.info, const Color(0xFF3B6FE0));
  });

  testWidgets('AppCard renders child', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: AppCard(child: Text('Test')),
        ),
      ),
    );
    expect(find.text('Test'), findsOneWidget);
  });

  testWidgets('AppChip renders label', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: AppChip(label: 'Status'),
        ),
      ),
    );
    expect(find.text('Status'), findsOneWidget);
  });

  testWidgets('AppEmptyState renders title', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: AppEmptyState(
            icon: Icons.inbox,
            title: 'No data',
          ),
        ),
      ),
    );
    expect(find.text('No data'), findsOneWidget);
  });
}
