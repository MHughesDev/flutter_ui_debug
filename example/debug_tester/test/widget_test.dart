// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/widgets.dart';

import 'package:debug_tester/main.dart';

void main() {
  testWidgets('tester app loads', (WidgetTester tester) async {
    await tester.pumpWidget(const DebugTesterApp());
    // The sample intentionally runs looping animations, so settle would timeout.
    await tester.pump(const Duration(milliseconds: 200));
    expect(find.text('UI Debug Tester'), findsOneWidget);
    expect(find.text('Tap Count: 0'), findsOneWidget);
  });

  testWidgets('debug command menu actions are functional', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const DebugTesterApp());
    await tester.pump(const Duration(milliseconds: 200));

    await tester.tap(find.byKey(const Key('toggleDebugMenuButton')));
    await tester.pump(const Duration(milliseconds: 100));
    expect(find.text('UI Debug Command Menu'), findsOneWidget);

    await tester.tap(find.text('Pause animations'));
    await tester.pump(const Duration(milliseconds: 80));
    expect(find.text('Resume animations'), findsOneWidget);

    await tester.tap(find.text('Hide object overlay'));
    await tester.pump(const Duration(milliseconds: 80));
    expect(find.text('Show object overlay'), findsOneWidget);

    await tester.tap(find.text('Capture snapshot'));
    await tester.pump(const Duration(milliseconds: 120));
    expect(find.text('Tracked objects'), findsOneWidget);
    expect(find.text('Tracked animations'), findsOneWidget);

    expect(find.textContaining('UI Debug Command Menu'), findsOneWidget);

    await tester.tap(find.text('Clear logs'));
    await tester.pump(const Duration(milliseconds: 80));
    expect(find.textContaining('overlay.open'), findsNothing);
  });
}
