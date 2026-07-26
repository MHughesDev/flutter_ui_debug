import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_ui_debug_example/app/debug_app.dart';

void main() {
  testWidgets('demo app loads first screen', (WidgetTester tester) async {
    await tester.pumpWidget(const DebugDemoApp());
    await tester.pump();

    expect(find.text('Comprehensive Showcase'), findsOneWidget);
  });
}
