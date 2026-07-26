import 'package:flutter/material.dart';
import 'package:flutter_ui_debug/flutter_ui_debug.dart';
import 'app/debug_app.dart';

void main() {
  // Always enable debug mode for the demo app
  kUIDebugMode = true;
  
  runApp(const DebugDemoApp());
}
