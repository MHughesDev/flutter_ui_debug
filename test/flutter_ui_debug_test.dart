import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_ui_debug/flutter_ui_debug.dart';

void main() {
  test('controller defaults are stable for host apps', () {
    final UiDebugController controller = UiDebugController();
    expect(controller.overlayVisible, isFalse);
    expect(controller.highlightObjects, isTrue);
    expect(controller.pauseAnimations, isFalse);
    expect(controller.logs, isEmpty);
  });
}
