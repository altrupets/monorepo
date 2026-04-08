import 'package:flutter_test/flutter_test.dart';

import 'package:b2g/main.dart';

void main() {
  testWidgets('App renders without error', (WidgetTester tester) async {
    await tester.pumpWidget(const AltruPetsB2GApp());
    await tester.pumpAndSettle();
  });
}
