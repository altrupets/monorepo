import 'package:altrupets/core/theme/token_service.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:widgetbook_workspace/main.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('WidgetbookApp smoke test', (WidgetTester tester) async {
    // AppTheme lee los design tokens vía TokenService — igual que main().
    await TokenService.initialize();

    await tester.pumpWidget(const WidgetbookApp());

    expect(find.text('AltruPets Design System'), findsOneWidget);
  });
}
