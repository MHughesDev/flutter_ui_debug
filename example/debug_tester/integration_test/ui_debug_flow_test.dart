import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:flutter/widgets.dart';

import 'package:debug_tester/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('tester app exercises interactions and debug menu', (
    WidgetTester tester,
  ) async {
    app.main();
    await tester.pumpAndSettle();

    expect(find.text('UI Debug Tester'), findsOneWidget);
    expect(find.byKey(const Key('tapCounterLabel')), findsOneWidget);
    expect(find.text('Tap Count: 0'), findsOneWidget);

    await tester.tap(find.byKey(const Key('incrementTapButton')));
    await tester.pumpAndSettle();
    expect(find.text('Tap Count: 1'), findsOneWidget);

    await tester.tap(find.byKey(const Key('togglePanelButton')));
    await tester.pumpAndSettle();
    expect(find.textContaining('Secondary panel visible'), findsNothing);

    await tester.tap(find.byKey(const Key('togglePanelButton')));
    await tester.pumpAndSettle();
    expect(find.textContaining('Secondary panel visible'), findsOneWidget);

    await tester.tap(find.byKey(const Key('toggleDebugMenuButton')));
    await tester.pumpAndSettle();
    expect(find.text('UI Debug Command Menu'), findsOneWidget);

    await tester.tap(find.text('Capture snapshot'));
    await tester.pumpAndSettle();
    expect(find.text('Tracked objects'), findsOneWidget);
    expect(find.text('Tracked animations'), findsOneWidget);
  });
}
